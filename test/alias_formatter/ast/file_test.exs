defmodule AliasFormatter.AST.FileTest do
  use ExUnit.Case

  alias AliasFormatter.AST.File

  describe "substitute/2" do
    test "should process alias when it is the only content" do
      {processed_alias_ast, unprocessed_alias_ast} = get_alias_asts([:One, :Two, :Three])

      assert {:__block__, [], [^processed_alias_ast]} = File.substitute(unprocessed_alias_ast)
    end

    test "should process and hoist aliases in file and defmodule" do
      file_level_name_path = [:One, :Two, :Three]

      {file_processed_alias, file_unprocessed_alias} = get_alias_asts(file_level_name_path)

      {defmodule_processed_alias, defmodule_unprocessed_alias} =
        get_alias_asts(file_level_name_path)

      input_ast =
        get_def_ast()
        |> then(&[&1, defmodule_unprocessed_alias])
        |> get_defmodule_ast()
        |> then(&[&1, file_unprocessed_alias])
        |> get_file_ast()

      expected_ast =
        get_def_ast()
        |> then(&[defmodule_processed_alias, &1])
        |> get_defmodule_ast()
        |> then(&[file_processed_alias, &1])
        |> get_file_ast()

      assert expected_ast == File.substitute(input_ast)
    end
  end

  defp get_file_ast(content_ast_list),
    do: {:__block__, [], content_ast_list}

  defp get_defmodule_ast(do_block_content) do
    {:defmodule, [line: 1],
     [
       {:__aliases__, [line: 1], [:TestModuleExample]},
       [
         do: {:__block__, [], do_block_content}
       ]
     ]}
  end

  defp get_def_ast do
    {:def, [line: 2],
     [
       {:first, [line: 2], nil},
       [do: "first"]
     ]}
  end

  defp get_alias_asts(name_path) do
    {unfinished_name_path, [last_module_name]} = Enum.split(name_path, -1)

    processed_alias_ast = get_processed_alias_ast(name_path)
    unprocessed_alias_ast = get_unprocessed_alias_ast(unfinished_name_path, last_module_name)

    {processed_alias_ast, unprocessed_alias_ast}
  end

  defp get_processed_alias_ast(name_path),
    do: {:alias, [line: 1], [{:__aliases__, [line: 1], name_path}]}

  defp get_unprocessed_alias_ast(name_path, last_module_name) do
    {:alias, [line: 1],
     [
       {{:., [line: 1], [{:__aliases__, [line: 1], name_path}, :{}]}, [line: 1],
        [{:__aliases__, [line: 1], [last_module_name]}]}
     ]}
  end
end

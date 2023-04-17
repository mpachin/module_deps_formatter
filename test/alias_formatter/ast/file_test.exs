defmodule AliasFormatter.AST.FileTest do
  use ExUnit.Case

  alias AliasFormatter.AST.File
  alias AliasFormatter.ContextAliasCollector

  describe "substitute/2" do
    test "should retrieve alias when it is the only content" do
      last_module_name = :Three
      name_path = [:One, :Two, last_module_name]
      alias_ast = get_alias_ast(name_path)

      assert {:__block__, [], []} = File.substitute(alias_ast)
    end

    test "should retrieve alias when it have other content" do
      last_module_name = :Three
      name_path = [:One, :Two, last_module_name]
      file_level_alias_ast = get_alias_ast(name_path)

      module_level_alias_ast = get_alias_ast(name_path ++ [:Four])

      defmodule_ast = get_defmodule_ast([module_level_alias_ast])

      input_ast = get_file_ast([file_level_alias_ast, defmodule_ast])
      expected_ast = [get_defmodule_ast()] |> get_file_ast()

      assert ^expected_ast = File.substitute(input_ast)
    end
  end

  defp get_file_ast(content_ast_list) do
    {:__block__, [], content_ast_list}
  end

  defp get_defmodule_ast(do_block_ast_list \\ []) do
    do_block_content =
      [
        {:def, [line: 2],
         [
           {:first, [line: 2], nil},
           [do: "first"]
         ]}
      ] ++ do_block_ast_list

    {:defmodule, [line: 1],
     [
       {:__aliases__, [line: 1], [:TestModuleExample]},
       [
         do: {:__block__, [], do_block_content}
       ]
     ]}
  end

  defp get_alias_ast(name_path) do
    {:alias, [line: 1], [{:__aliases__, [line: 1], name_path}]}
  end
end

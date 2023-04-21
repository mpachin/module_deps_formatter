defmodule AliasFormatter.AST.DefmoduleTest do
  use ExUnit.Case

  alias AliasFormatter.AST.Defmodule

  describe "substitute/2" do
    test "should change defmodule ast to use block do...end" do
      do_block_ast_list_without_aliases = get_do_block_ast_list_without_aliases()

      expected_ast =
        do_block_ast_list_without_aliases
        |> get_defmodule_ast_formatted_right()

      assert ^expected_ast =
               do_block_ast_list_without_aliases
               |> get_defmodule_ast_formatted_wrong()
               |> Defmodule.substitute()
    end

    test "should keep defmodule ast untouched if it has correct structure" do
      expected_ast =
        get_do_block_ast_list_without_aliases()
        |> get_defmodule_ast_formatted_right()

      assert ^expected_ast = Defmodule.substitute(expected_ast)
    end

    test "should hoist alias from def to defmodule level" do
      last_module_name = :Three
      name_path = [:One, :Two, last_module_name]
      alias_ast = name_path |> get_alias_ast()

      expected_ast =
        ([alias_ast] ++ get_do_block_ast_list_without_aliases())
        |> get_defmodule_ast_formatted_right()

      assert expected_ast ==
               [alias_ast]
               |> get_do_block_ast_list_with_alias()
               |> get_defmodule_ast_formatted_right()
               |> Defmodule.substitute()
    end

    test "should retrieve alias when it is the only content" do
      last_module_name = :Three
      name_path = [:One, :Two, last_module_name]
      alias_ast = name_path |> get_alias_ast()

      original_ast =
        alias_ast
        |> get_defmodule_ast_formatted_right()

      expected_ast = [alias_ast] |> get_defmodule_ast_formatted_right()

      assert expected_ast == original_ast |> Defmodule.substitute()
    end
  end

  defp get_defmodule_ast_formatted_wrong(do_block_ast_list) do
    {:defmodule, [line: 1],
     [
       {:__aliases__, [line: 1], [:TestModuleExample]},
       [
         {
           {:__block__, [line: 1], [:do]},
           {:__block__, [], do_block_ast_list}
         }
       ]
     ]}
  end

  defp get_defmodule_ast_formatted_right(do_block_ast_list) do
    {:defmodule, [line: 1],
     [
       {:__aliases__, [line: 1], [:TestModuleExample]},
       [do: {:__block__, [], do_block_ast_list}]
     ]}
  end

  defp get_do_block_ast_list_without_aliases do
    [
      {:def, [line: 2],
       [
         {:first, [line: 2], nil},
         [do: "first"]
       ]}
    ]
  end

  defp get_do_block_ast_list_with_alias(alias_ast_list) do
    [
      {:def, [line: 2],
       [
         {:first, [line: 2], nil},
         [
           {{:__block__, [line: 2], [:do]},
            {:__block__, [],
             alias_ast_list ++
               [
                 {:__block__, [line: 4], ["first"]}
               ]}}
         ]
       ]}
    ]
  end

  defp get_alias_ast(name_path) do
    {:alias, [line: 1], [{:__aliases__, [line: 1], name_path}]}
  end
end

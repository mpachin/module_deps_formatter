defmodule AliasFormatter.AST.DefmoduleTest do
  use ExUnit.Case

  alias AliasFormatter.AST.Defmodule

  setup do
    last_module_name = :Three
    name_path = [:One, :Two, last_module_name]
    alias_ast = name_path |> get_alias_ast()

    %{alias_ast: alias_ast}
  end

  describe "substitute/2" do
    test "should change defmodule ast to use block do...end" do
      do_block_ast_list_without_aliases = get_do_block_ast_list_without_aliases()

      expected_ast =
        do_block_ast_list_without_aliases
        |> get_defmodule_ast_formatted_right()

      assert ^expected_ast =
               do_block_ast_list_without_aliases
               |> get_defmodule_block_list_ast()
               |> substitute()
    end

    test "should keep defmodule ast untouched if it has correct structure" do
      expected_ast =
        get_do_block_ast_list_without_aliases()
        |> get_defmodule_ast_formatted_right()

      assert ^expected_ast = substitute(expected_ast)
    end

    test "should hoist alias from def to defmodule level", %{
      alias_ast: alias_ast
    } do
      expected_ast =
        ([alias_ast] ++ get_do_block_ast_list_without_aliases())
        |> get_defmodule_ast_formatted_right()

      assert expected_ast ==
               [alias_ast]
               |> get_do_block_ast_list_with_alias()
               |> get_defmodule_ast_formatted_right()
               |> substitute()
    end

    test "should retrieve alias when it is the only content in do: {:__block__, ...} format", %{
      alias_ast: alias_ast
    } do
      original_ast = alias_ast |> get_defmodule_ast_formatted_right()

      expected_ast = [alias_ast] |> get_defmodule_ast_formatted_right()

      assert expected_ast == original_ast |> substitute()
    end

    test "should retrieve alias when it is the only content in {:__block__, _, [:do]} format", %{
      alias_ast: alias_ast
    } do
      original_ast = alias_ast |> get_defmodule_block_singular_content_ast()

      expected_ast = [alias_ast] |> get_defmodule_ast_formatted_right()

      assert expected_ast == original_ast |> substitute()
    end
  end

  defp substitute(ast, previous_context_aliases \\ {%{}, %{}, %{}}) do
    Defmodule.substitute(ast, previous_context_aliases)
  end

  defp get_defmodule_block_singular_content_ast(do_block_ast) do
    do_block_ast
    |> then(&[{{:__block__, [line: 1], [:do]}, &1}])
    |> get_defmodule_ast_template()
  end

  defp get_defmodule_block_list_ast(do_block_ast_list) do
    do_block_ast_list
    |> then(
      &[
        {
          {:__block__, [line: 1], [:do]},
          {:__block__, [], &1}
        }
      ]
    )
    |> get_defmodule_ast_template()
  end

  defp get_defmodule_ast_formatted_right(do_block_ast_list) do
    do_block_ast_list
    |> then(&[do: {:__block__, [], &1}])
    |> get_defmodule_ast_template()
  end

  defp get_defmodule_ast_template(ast_content) do
    {:defmodule, [line: 1],
     [
       {:__aliases__, [line: 1], [:TestModuleExample]},
       ast_content
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

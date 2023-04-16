defmodule AliasFormatter.AST.DefmoduleTest do
  use ExUnit.Case

  alias AliasFormatter.AST.Defmodule
  alias AliasFormatter.ContextAliasCollector

  setup do
    pid = ContextAliasCollector.start_link([])
    [pid: pid]
  end

  describe "substitute/2" do
    test "should change defmodule ast to use block do...end", %{pid: pid} do
      do_block_ast_list_without_aliases = get_do_block_ast_list_without_aliases()

      expected_ast =
        do_block_ast_list_without_aliases
        |> get_defmodule_ast_formatted_right()

      assert ^expected_ast =
               do_block_ast_list_without_aliases
               |> get_defmodule_ast_formatted_wrong()
               |> Defmodule.substitute(pid)

      assert [] = ContextAliasCollector.get_result_aliases(pid)
    end

    test "should keep defmodule ast untouched if it has correct structure", %{pid: pid} do
      expected_ast =
        get_do_block_ast_list_without_aliases()
        |> get_defmodule_ast_formatted_right()

      assert ^expected_ast = Defmodule.substitute(expected_ast, pid)
      assert [] = ContextAliasCollector.get_result_aliases(pid)
    end

    test "should retrieve alias from ast", %{pid: pid} do
      last_module_name = :Three
      name_path = [:One, :Two, last_module_name]
      do_block_ast_list_with_alias = get_do_block_ast_list_with_alias(name_path)

      expected_ast =
        get_do_block_ast_list_without_aliases()
        |> get_defmodule_ast_formatted_right()

      assert ^expected_ast =
               do_block_ast_list_with_alias
               |> get_defmodule_ast_formatted_right()
               |> Defmodule.substitute(pid)

      assert [{^name_path, ^last_module_name}] = ContextAliasCollector.get_result_aliases(pid)
    end

    test "should retrieve alias when it is the only content", %{pid: pid} do
      last_module_name = :Three
      name_path = [:One, :Two, last_module_name]
      alias_ast = get_alias_ast(name_path)

      expected_ast = get_defmodule_ast_formatted_right([])

      assert ^expected_ast =
               alias_ast
               |> get_defmodule_ast_formatted_right()
               |> Defmodule.substitute(pid)

      assert [{^name_path, ^last_module_name}] = ContextAliasCollector.get_result_aliases(pid)
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

  defp get_do_block_ast_list_with_alias(name_path) do
    alias_ast = get_alias_ast(name_path)

    do_block_ast_list_without_aliases = get_do_block_ast_list_without_aliases()

    do_block_ast_list_without_aliases ++ [alias_ast]
  end

  defp get_alias_ast(name_path) do
    {:alias, [line: 5], [{:__aliases__, [line: 5], name_path}]}
  end
end

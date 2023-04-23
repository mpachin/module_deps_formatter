defmodule AliasFormatter.AST.DefTest do
  use ExUnit.Case

  alias AliasFormatter.AST.Def
  alias AliasFormatter.ContextAliasCollector

  setup do
    pid = ContextAliasCollector.start_link([])
    [pid: pid]
  end

  describe "substitute/1" do
    test "should change function ast if format: :keyword option isn't presented", %{pid: pid} do
      expected_ast = get_def_without_block("first")

      test_ast =
        {:__block__, [line: 2], ["first"]}
        |> get_def_with_block()

      assert expected_ast == Def.substitute(test_ast, pid)

      assert_result_aliases([], pid)
    end

    test "should keep function ast unchanged if format: :keyword is presented", %{pid: pid} do
      test_function_ast =
        [
          {
            {:__block__, [format: :keyword, line: 2], [:do]},
            {:__block__, [line: 2], ["first"]}
          }
        ]
        |> get_def_template()

      assert test_function_ast == Def.substitute(test_function_ast, pid)

      assert_result_aliases([], pid)
    end

    test "shouldn't change alias asts", %{pid: pid} do
      test_alias_asts = [
        {:alias, [line: 3], [{:__aliases__, [line: 3], [:TestModuleExample, :Bbb]}]},
        {:alias, [line: 3],
         [
           {:__aliases__, [line: 3], [:TestModuleExample, :Bbb]},
           [
             {{:__block__, [format: :keyword, line: 3], [:as]}, {:__aliases__, [line: 3], [:Aaa]}}
           ]
         ]}
      ]

      for test_alias_ast <- test_alias_asts do
        assert test_alias_ast == Def.substitute(test_alias_ast, pid)
      end

      assert_result_aliases([], pid)
    end

    test "should remove aliases from def bodies and return alias pairs list", %{pid: pid} do
      test_name_path = [:Aoeu, :Alias]
      test_alias_as = List.last(test_name_path)

      function_call_ast =
        {{:., [line: 5], [{:__aliases__, [line: 5], [test_alias_as]}, :alias_fun]}, [line: 5], []}

      test_ast =
        {:__block__, [],
         [
           {:alias, [line: 4], [{:__aliases__, [line: 4], test_name_path}]},
           function_call_ast
         ]}
        |> get_def_with_block()

      expected_ast =
        [function_call_ast]
        |> get_def_without_block()

      assert expected_ast == Def.substitute(test_ast, pid)

      [{test_name_path, test_alias_as}]
      |> assert_result_aliases(pid)
    end

    test "should unwrap __block__ to do: when it is the only ast content left", %{pid: pid} do
      test_name_path = [:One, :Two, :Three]
      test_alias_as = List.last(test_name_path)

      original_ast =
        {:__block__, [],
         [
           {:alias, [line: 1], [{:__aliases__, [line: 1], test_name_path}]},
           {:__block__, [line: 4], ["first"]}
         ]}
        |> get_def_with_block()

      expected_ast = get_def_without_block("first")

      assert expected_ast == Def.substitute(original_ast, pid)

      [{test_name_path, test_alias_as}]
      |> assert_result_aliases(pid)
    end

    test "should retrieve alias when it is the only content in {:__block__, _, [:do]} format", %{
      pid: pid
    } do
      test_name_path = [:One, :Two, :Three]
      test_alias_as = List.last(test_name_path)

      original_ast =
        {:alias, [line: 1], [{:__aliases__, [line: 1], test_name_path}]}
        |> get_def_with_block()

      expected_ast = get_def_without_block(nil)

      assert expected_ast == Def.substitute(original_ast, pid)

      [{test_name_path, test_alias_as}]
      |> assert_result_aliases(pid)
    end
  end

  defp assert_result_aliases(expected_alias_pairs, pid) do
    assert {^expected_alias_pairs, _} = ContextAliasCollector.get_result_aliases(pid)
  end

  defp get_def_template(def_ast_content) do
    {:def, [line: 2],
     [
       {:test_function_name, [line: 2], nil},
       def_ast_content
     ]}
  end

  defp get_def_with_block(block_ast_content) do
    [
      {
        {:__block__, [line: 2], [:do]},
        block_ast_content
      }
    ]
    |> get_def_template()
  end

  defp get_def_without_block(ast_content) do
    [do: ast_content]
    |> get_def_template()
  end
end

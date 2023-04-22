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
      assert {:def, [line: 2], [{:test_fun_name, [line: 2], nil}, [do: "first"]]} =
               {:def, [line: 2],
                [
                  {:test_fun_name, [line: 2], nil},
                  [
                    {
                      {:__block__, [line: 2], [:do]},
                      {:__block__, [line: 2], ["first"]}
                    }
                  ]
                ]}
               |> Def.substitute(pid)

      assert {[], _} = ContextAliasCollector.get_result_aliases(pid)
    end

    test "should keep function ast unchanged if format: :keyword is presented", %{pid: pid} do
      test_function_ast =
        {:def, [line: 2],
         [
           {:test_fun_name, [line: 2], nil},
           [
             {
               {:__block__, [format: :keyword, line: 2], [:do]},
               {:__block__, [line: 2], ["first"]}
             }
           ]
         ]}

      assert ^test_function_ast = Def.substitute(test_function_ast, pid)

      assert {[], _} = ContextAliasCollector.get_result_aliases(pid)
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
        assert ^test_alias_ast = Def.substitute(test_alias_ast, pid)
      end

      assert {[], _} = ContextAliasCollector.get_result_aliases(pid)
    end

    test "should remove aliases from def bodies and return alias pairs list", %{pid: pid} do
      test_name_path = [:Aoeu, :Alias]
      test_alias_as = List.last(test_name_path)

      expected_alias_pairs = [{test_name_path, test_alias_as}]

      test_ast =
        {:def, [line: 3],
         [
           {:test_fun, [line: 3], nil},
           [
             {{:__block__, [line: 3], [:do]},
              {:__block__, [],
               [
                 {:alias, [line: 4], [{:__aliases__, [line: 4], test_name_path}]},
                 {{:., [line: 5], [{:__aliases__, [line: 5], [:Alias]}, :alias_fun]}, [line: 5],
                  []}
               ]}}
           ]
         ]}

      expected_result_ast =
        {:def, [line: 3],
         [
           {:test_fun, [line: 3], nil},
           [
             do: [
               {{:., [line: 5], [{:__aliases__, [line: 5], [:Alias]}, :alias_fun]}, [line: 5], []}
             ]
           ]
         ]}

      assert ^expected_result_ast = Def.substitute(test_ast, pid)

      assert {^expected_alias_pairs, _} = ContextAliasCollector.get_result_aliases(pid)
    end

    test "should unwrap __block__ to do: when it is the only ast content left", %{pid: pid} do
      test_name_path = [:One, :Two, :Three]
      test_alias_as = List.last(test_name_path)

      expected_alias_pairs = [{test_name_path, test_alias_as}]

      original_ast =
        {:def, [line: 2],
         [
           {:first, [line: 2], nil},
           [
             {{:__block__, [line: 2], [:do]},
              {:__block__, [],
               [
                 {:alias, [line: 1], [{:__aliases__, [line: 1], test_name_path}]},
                 {:__block__, [line: 4], ["first"]}
               ]}}
           ]
         ]}

      expected_ast =
        {:def, [line: 2],
         [
           {:first, [line: 2], nil},
           [do: "first"]
         ]}

      assert expected_ast == Def.substitute(original_ast, pid)

      assert {^expected_alias_pairs, _} = ContextAliasCollector.get_result_aliases(pid)
    end
  end
end

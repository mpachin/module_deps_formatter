defmodule AliasFormatter.DefSubstituteTest do
  use ExUnit.Case

  alias AliasFormatter.DefSubstitute

  describe "substitute/1" do
    test "should change function ast if format: :keyword option isn't presented" do
      assert {[], {:def, [line: 2], [{:test_fun_name, [line: 2], nil}, [do: "first"]]}} =
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
               |> DefSubstitute.substitute()
    end

    test "should keep function ast unchanged if format: :keyword is presented" do
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

      assert {[], ^test_function_ast} = DefSubstitute.substitute(test_function_ast)
    end

    test "shouldn't change alias asts" do
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
        assert {[], ^test_alias_ast} = DefSubstitute.substitute(test_alias_ast)
      end
    end

    test "should remove aliases from def bodies and return alias pairs list" do
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

      assert {^expected_alias_pairs, ^expected_result_ast} = DefSubstitute.substitute(test_ast)
    end
  end
end

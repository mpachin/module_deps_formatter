defmodule AliasFormatter.DefSubstituteTest do
  use ExUnit.Case

  alias AliasFormatter.DefSubstitute

  describe "substitute/1" do
    test "should change function ast if format: :keyword option isn't presented" do
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

      assert ^test_function_ast = test_function_ast |> DefSubstitute.substitute()
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
        assert ^test_alias_ast = test_alias_ast |> DefSubstitute.substitute()
      end
    end
  end
end

defmodule AliasFormatter.KeywordSubstituteTest do
  use ExUnit.Case

  alias AliasFormatter.KeywordSubstitute

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
               |> KeywordSubstitute.substitute()
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

      assert ^test_function_ast = test_function_ast |> KeywordSubstitute.substitute()
    end
  end
end
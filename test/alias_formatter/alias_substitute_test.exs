defmodule AliasFormatter.AliasSubstituteTest do
  use ExUnit.Case

  alias AliasFormatter.AliasSubstitute

  describe "substitute/1" do
    test "should change alias ast from short form to explicit multiline form" do
      assert [
               {:__aliases__, [line: 2], [:TestModuleExample, :Ccc]},
               {:__aliases__, [line: 2], [:TestModuleExample, :Aaa]},
               {:__aliases__, [line: 2], [:TestModuleExample, :Bbb]}
             ] =
               {:alias, [line: 2],
                [
                  {{:., [line: 2], [{:__aliases__, [line: 2], [:TestModuleExample]}, :{}]},
                   [line: 2],
                   [
                     {:__aliases__, [line: 2], [:Ccc]},
                     {:__aliases__, [line: 2], [:Aaa]},
                     {:__aliases__, [line: 2], [:Bbb]}
                   ]}
                ]}
               |> AliasSubstitute.substitute()
    end

    test "should correctly change alias ast with complex nesting" do
      assert [
               {:__aliases__, [line: 2], [:TestModuleExample, :Nested, :One, :Ccc]},
               {:__aliases__, [line: 2], [:TestModuleExample, :Nested, :Two, :Aaa]},
               {:__aliases__, [line: 2], [:TestModuleExample, :Nested, :Three, :Bbb]}
             ] =
               {:alias, [line: 2],
                [
                  {{:., [line: 2],
                    [{:__aliases__, [line: 2], [:TestModuleExample, :Nested]}, :{}]}, [line: 2],
                   [
                     {:__aliases__, [line: 2], [:One, :Ccc]},
                     {:__aliases__, [line: 2], [:Two, :Aaa]},
                     {:__aliases__, [line: 2], [:Three, :Bbb]}
                   ]}
                ]}
               |> AliasSubstitute.substitute()
    end
  end
end

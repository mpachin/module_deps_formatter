defmodule AliasFormatter.AliasDeduplicateTest do
  use ExUnit.Case

  alias AliasFormatter.AliasDeduplicate

  describe "deduplicate/1" do
    test "should remove alias asts with duplicate names" do
      assert [
               {:alias, [line: 2], [{:__aliases__, [line: 2], [:TestModuleExample, :Aaa]}]}
             ] =
               [
                 {:alias, [line: 2], [{:__aliases__, [line: 2], [:TestModuleExample, :Aaa]}]},
                 {:alias, [line: 2], [{:__aliases__, [line: 2], [:TestModuleExample, :Aaa]}]},
                 {:alias, [line: 2], [{:__aliases__, [line: 2], [:TestModuleExample, :Aaa]}]}
               ]
               |> AliasDeduplicate.deduplicate()
    end
  end
end

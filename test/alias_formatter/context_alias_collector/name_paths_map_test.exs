defmodule AliasFormatter.ContextAliasCollector.NamePathsMapTest do
  use ExUnit.Case

  alias AliasFormatter.ContextAliasCollector.NamePathsMap

  test "should return short alias version" do
    test_alias_data = {[:Test, :Module, :Aaa], :Aaa}

    assert %{
             Test: %{
               Module: %{
                 Aaa: :Aaa
               }
             }
           } = NamePathsMap.add_alias(test_alias_data)
  end
end

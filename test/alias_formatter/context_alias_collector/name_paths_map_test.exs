defmodule AliasFormatter.ContextAliasCollector.NamePathsMapTest do
  use ExUnit.Case

  alias AliasFormatter.ContextAliasCollector.NamePathsMap

  test "should update given map with alias data" do
    test_alias_data = {[:Test, :Module, :Aaa], :Aaa}

    assert %{
             Test: %{
               Module: %{
                 Aaa: :Aaa
               }
             }
           } = NamePathsMap.add_alias(%{}, test_alias_data)
  end
end

defmodule AliasFormatter.ContextAliasCollectorTest do
  use ExUnit.Case

  alias AliasFormatter.ContextAliasCollector
  alias GenServer

  setup do
    pid = ContextAliasCollector.start_link([])
    [pid: pid]
  end

  describe "get_short_module_name" do
    test "should return short alias version", %{pid: pid} do
      test_alias_data = {[:Test, :Module], :AsThis}
      ContextAliasCollector.add_alias_data(pid, test_alias_data)

      assert [:Module] = ContextAliasCollector.get_short_name(pid, [:Test, :Module])
    end
  end
end

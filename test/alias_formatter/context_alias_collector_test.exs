defmodule AliasFormatter.ContextAliasCollectorTest do
  use ExUnit.Case

  alias AliasFormatter.ContextAliasCollector
  alias GenServer

  setup do
    pid = ContextAliasCollector.start_link([])
    [pid: pid]
  end

  describe "get_short_name/2" do
    test "should return existing short alias version", %{pid: pid} do
      {name_path, as_alias} = test_alias_data = {[:Test, :Module], :AsThis}

      ContextAliasCollector.add_alias(pid, test_alias_data)

      assert ^as_alias = ContextAliasCollector.get_short_name(pid, name_path)
    end

    test "get_short_name/2 should add new alias", %{pid: pid} do
      {name_path, as_alias} = test_alias_data = {[:Test, :Module], :AsThis}
      new_last_name = :Aaa
      new_name_path = name_path ++ [new_last_name]

      ContextAliasCollector.add_alias(pid, test_alias_data)

      assert ^as_alias = ContextAliasCollector.get_short_name(pid, name_path)
      assert ^new_last_name = ContextAliasCollector.get_short_name(pid, new_name_path)
    end
  end

  describe "get_result_aliases/1" do
    test "should return result aliases as sorted list", %{pid: pid} do
      [
        {[:Aaa, :Bbb, :Ccc], :CccAliasAs},
        {[:Aaa, :Bbb], :Bbb},
        {[:Aaa, :Yyy], :YyyAliasAs}
      ]
      |> Enum.each(fn test_alias_data ->
        ContextAliasCollector.add_alias(pid, test_alias_data)
      end)

      assert [
               {[:Aaa, :Bbb], :Bbb},
               {[:Aaa, :Bbb, :Ccc], :CccAliasAs},
               {[:Aaa, :Yyy], :YyyAliasAs}
             ] = ContextAliasCollector.get_result_aliases(pid)
    end
  end
end

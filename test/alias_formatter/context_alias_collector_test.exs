defmodule AliasFormatter.ContextAliasCollectorTest do
  use ExUnit.Case

  alias AliasFormatter.ContextAliasCollector
  alias GenServer

  setup do
    pid = ContextAliasCollector.start_link()
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
    test "should return result aliases, genserver state and should close genserver process", %{
      pid: pid
    } do
      [
        {[:Aaa, :Bbb, :Ccc], :CccAliasAs},
        {[:Aaa, :Bbb], :Bbb},
        {[:Aaa, :Yyy], :YyyAliasAs}
      ]
      |> Enum.each(fn test_alias_data ->
        ContextAliasCollector.add_alias(pid, test_alias_data)
      end)

      expected_state = {
        %{
          [:Aaa, :Bbb] => :Bbb,
          [:Aaa, :Bbb, :Ccc] => :CccAliasAs,
          [:Aaa, :Yyy] => :YyyAliasAs
        },
        %{
          Bbb: [:Aaa, :Bbb],
          CccAliasAs: [:Aaa, :Bbb, :Ccc],
          YyyAliasAs: [:Aaa, :Yyy]
        },
        %{
          Bbb: 1,
          CccAliasAs: 1,
          YyyAliasAs: 1
        }
      }

      assert {[
                {[:Aaa, :Bbb], :Bbb},
                {[:Aaa, :Bbb, :Ccc], :CccAliasAs},
                {[:Aaa, :Yyy], :YyyAliasAs}
              ], ^expected_state} = ContextAliasCollector.get_result_aliases(pid)

      assert not Process.alive?(pid)
    end

    test "should not include aliases from previous context but should preserve them in returned state" do
      {prev_test_name_path, prev_test_alias_as} = prev_context_alias_data = {[:Aaa, :Bbb], :Bbb}

      {test_name_path, test_alias_as} = test_alias_data = {[:Aaa, :Bbb, :Ccc], :CccAliasAs}

      prev_paths_to_leaf = %{prev_test_name_path => prev_test_alias_as}
      prev_leaf_to_path = %{prev_test_alias_as => prev_test_name_path}
      prev_leaf_to_increment = %{prev_test_alias_as => 1}

      previous_context_state = {
        prev_paths_to_leaf,
        prev_leaf_to_path,
        prev_leaf_to_increment
      }

      expected_state = {
        prev_paths_to_leaf |> Map.put(test_name_path, test_alias_as),
        prev_leaf_to_path |> Map.put(test_alias_as, test_name_path),
        prev_leaf_to_increment |> Map.put(test_alias_as, 1)
      }

      expected_returned_result = {[test_alias_data], expected_state}

      [
        [test_alias_data],
        [prev_context_alias_data, test_alias_data]
      ]
      |> Enum.each(fn aliases_to_add ->
        pid = ContextAliasCollector.start_link(previous_context_state)

        aliases_to_add
        |> Enum.each(fn test_alias_data ->
          ContextAliasCollector.add_alias(pid, test_alias_data)
        end)

        assert expected_returned_result == ContextAliasCollector.get_result_aliases(pid)
      end)
    end
  end
end

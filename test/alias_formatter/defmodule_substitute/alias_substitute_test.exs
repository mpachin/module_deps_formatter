defmodule AliasFormatter.DefmoduleSubstitute.AliasSubstituteTest do
  use ExUnit.Case

  alias AliasFormatter.ContextAliasCollector
  alias AliasFormatter.DefmoduleSubstitute.AliasSubstitute

  setup do
    pid = ContextAliasCollector.start_link([])
    [pid: pid]
  end

  describe "substitute/2" do
    test "should populate alias collector with simple alias", %{pid: pid} do
      test_last_module = :Three
      test_name_path = [:One, :Two, test_last_module]

      {:alias, [line: 2], [{:__aliases__, [line: 2], test_name_path}]}
      |> AliasSubstitute.substitute(pid)

      assert [{^test_name_path, ^test_last_module}] =
               ContextAliasCollector.get_result_aliases(pid)
    end

    test "should populate alias collector with alias as", %{pid: pid} do
      expected_alias_as = :As
      test_name_path = [:One, :Two, :Three]
      alias_as_list = [expected_alias_as]

      {:alias, [line: 2],
       [
         {:__aliases__, [line: 2], test_name_path},
         [
           {{:__block__, [format: :keyword, line: 2], [:as]},
            {:__aliases__, [line: 2], alias_as_list}}
         ]
       ]}
      |> AliasSubstitute.substitute(pid)

      assert [{^test_name_path, ^expected_alias_as}] =
               ContextAliasCollector.get_result_aliases(pid)
    end

    test "should populate alias collector with long alias as", %{pid: pid} do
      expected_alias_as = :As
      test_name_path = [:One, :Two, :Three]
      alias_as_list = [:Ignored, :Alias, :As, :Parts, expected_alias_as]

      {:alias, [line: 2],
       [
         {:__aliases__, [line: 2], test_name_path},
         [
           {{:__block__, [format: :keyword, line: 2], [:as]},
            {:__aliases__, [line: 2], alias_as_list}}
         ]
       ]}
      |> AliasSubstitute.substitute(pid)

      assert [{^test_name_path, ^expected_alias_as}] =
               ContextAliasCollector.get_result_aliases(pid)
    end

    test "should populate alias collector with unwrapped short form aliases", %{pid: pid} do
      test_name_path = [:One, :Two, :Three]
      name_path_postfix_1 = [:Postfix, :First]
      name_path_postfix_2 = [:Postfix, :Second]

      expected_name_path_1 = test_name_path ++ name_path_postfix_1
      expected_name_path_2 = test_name_path ++ name_path_postfix_2
      expected_alias_as_1 = List.last(name_path_postfix_1)
      expected_alias_as_2 = List.last(name_path_postfix_2)

      {:alias, [line: 2],
       [
         {{:., [line: 2], [{:__aliases__, [line: 2], test_name_path}, :{}]}, [line: 2],
          [
            {:__aliases__, [line: 2], name_path_postfix_1},
            {:__aliases__, [line: 2], name_path_postfix_2}
          ]}
       ]}
      |> AliasSubstitute.substitute(pid)

      assert [
               {^expected_name_path_1, ^expected_alias_as_1},
               {^expected_name_path_2, ^expected_alias_as_2}
             ] = ContextAliasCollector.get_result_aliases(pid)
    end
  end
end

defmodule AliasFormatter.AST.AliasTest do
  use ExUnit.Case

  alias AliasFormatter.AST.Alias
  alias AliasFormatter.ContextAliasCollector

  setup do
    pid = ContextAliasCollector.start_link([])
    [pid: pid]
  end

  describe "retrieve_aliases_from_ast/2" do
    test "should remove aliases from ast list and populate alias collector", %{pid: pid} do
      expected_alias_list = [
        {{:., [line: 4], [{:__aliases__, [line: 4], [:Three]}, :fun]}, [line: 4], []}
      ]

      {alias_ast_list, retrieved_aliases} =
        [
          get_test_simple_form_alias(),
          get_test_alias_as_form(),
          get_test_long_alias_as_form(),
          get_test_short_form_alias()
        ]
        |> Enum.unzip()

      test_ast_list = alias_ast_list ++ expected_alias_list

      expected_retrieved_aliases = Enum.concat(retrieved_aliases)

      assert ^expected_alias_list =
               test_ast_list
               |> Alias.retrieve_aliases_from_ast(pid)

      assert {^expected_retrieved_aliases, _} = ContextAliasCollector.get_result_aliases(pid)
    end
  end

  describe "get_result_context_aliases/1" do
    test "should return aliases ast list", %{pid: pid} do
      first_name_path = [:Aaa, :Bbb]
      first_alias_as = List.last(first_name_path)

      second_name_path = [:Aaa, :Bbb, :Ccc]
      second_alias_as = :CccAliasAs

      [
        {first_name_path, first_alias_as},
        {second_name_path, second_alias_as}
      ]
      |> Enum.map(&ContextAliasCollector.add_alias(pid, &1))

      expected_state = {
        %{
          [:Aaa, :Bbb] => :Bbb,
          [:Aaa, :Bbb, :Ccc] => :CccAliasAs
        },
        %{
          Bbb: [:Aaa, :Bbb],
          CccAliasAs: [:Aaa, :Bbb, :Ccc]
        },
        %{Bbb: 1, CccAliasAs: 1}
      }

      assert {[
                {:alias, [line: 1], [{:__aliases__, [line: 1], ^first_name_path}]},
                {:alias, [line: 1],
                 [
                   {:__aliases__, [line: 1], ^second_name_path},
                   [
                     {{:__block__, [format: :keyword, line: 1], [:as]},
                      {:__aliases__, [line: 1], ^second_alias_as}}
                   ]
                 ]}
              ], ^expected_state} = Alias.get_result_context_aliases(pid)
    end
  end

  defp get_test_simple_form_alias do
    test_last_module = :Two
    test_name_path = [:One, test_last_module]

    simple_form_alias = {:alias, [line: 2], [{:__aliases__, [line: 2], test_name_path}]}

    expected_retrieved_simple_form_aliases = [{test_name_path, test_last_module}]

    {simple_form_alias, expected_retrieved_simple_form_aliases}
  end

  defp get_test_alias_as_form do
    expected_alias_as = :As
    test_name_path = [:One, :Two, :Three]
    alias_as_list = [expected_alias_as]

    alias_as_form =
      {:alias, [line: 2],
       [
         {:__aliases__, [line: 2], test_name_path},
         [
           {{:__block__, [format: :keyword, line: 2], [:as]},
            {:__aliases__, [line: 2], alias_as_list}}
         ]
       ]}

    expected_retrieved_alias_as_form = [{test_name_path, expected_alias_as}]

    {alias_as_form, expected_retrieved_alias_as_form}
  end

  defp get_test_long_alias_as_form do
    expected_alias_as = :LongAliasAs
    test_name_path = [:One, :Two, :Three, :Four]
    alias_as_list = [:Ignored, :Alias, :As, :Parts, expected_alias_as]

    long_alias_as_form =
      {:alias, [line: 2],
       [
         {:__aliases__, [line: 2], test_name_path},
         [
           {{:__block__, [format: :keyword, line: 2], [:as]},
            {:__aliases__, [line: 2], alias_as_list}}
         ]
       ]}

    expected_retrieved_long_alias_as_form = [{test_name_path, expected_alias_as}]

    {long_alias_as_form, expected_retrieved_long_alias_as_form}
  end

  defp get_test_short_form_alias do
    test_name_path = [:One, :Two, :Three, :Four, :Five]
    name_path_postfix_1 = [:Postfix, :First]
    name_path_postfix_2 = [:Postfix, :Second]

    expected_name_path_1 = test_name_path ++ name_path_postfix_1
    expected_name_path_2 = test_name_path ++ name_path_postfix_2
    expected_alias_as_1 = List.last(name_path_postfix_1)
    expected_alias_as_2 = List.last(name_path_postfix_2)

    short_form_alias =
      {:alias, [line: 3],
       [
         {{:., [line: 3], [{:__aliases__, [line: 3], test_name_path}, :{}]}, [line: 3],
          [
            {:__aliases__, [line: 3], name_path_postfix_1},
            {:__aliases__, [line: 3], name_path_postfix_2}
          ]}
       ]}

    expected_retrieved_short_form_aliases = [
      {expected_name_path_1, expected_alias_as_1},
      {expected_name_path_2, expected_alias_as_2}
    ]

    {short_form_alias, expected_retrieved_short_form_aliases}
  end
end

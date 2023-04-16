defmodule AliasFormatter.DefmoduleSubstitute.AliasSubstitute do
  alias AliasFormatter.AST
  alias AliasFormatter.ContextAliasCollector

  def retrieve_aliases_from_ast(ast_list, alias_collector_pid) do
    {alias_asts_list, rest_asts_list} = AST.split_aliases(ast_list)

    alias_asts_list
    |> Enum.each(&substitute(&1, alias_collector_pid))

    rest_asts_list
  end

  defp substitute(
         {:alias, _, [{:__aliases__, _, name_path}]},
         alias_collector_pid
       ) do
    alias_as = List.last(name_path)

    alias_collector_pid
    |> ContextAliasCollector.add_alias({name_path, alias_as})
  end

  defp substitute(
         {:alias, _,
          [
            {:__aliases__, _, name_path},
            [
              {
                {:__block__, _, [:as]},
                {:__aliases__, _, alias_as_list}
              }
            ]
          ]},
         alias_collector_pid
       ) do
    alias_as = List.last(alias_as_list)

    alias_collector_pid
    |> ContextAliasCollector.add_alias({name_path, alias_as})
  end

  defp substitute(
         {
           :alias,
           _,
           [
             {
               {:., _,
                [
                  {:__aliases__, _, partial_name_path},
                  :{}
                ]},
               _,
               alias_postfixes_list
             }
           ]
         },
         alias_collector_pid
       ) do
    alias_postfixes_list
    |> Enum.each(fn {:__aliases__, _, alias_postfix_atoms} ->
      full_alias_name_path = partial_name_path ++ alias_postfix_atoms
      alias_as = List.last(alias_postfix_atoms)

      alias_collector_pid
      |> ContextAliasCollector.add_alias({full_alias_name_path, alias_as})
    end)
  end

  defp substitute(ast_fragment, _alias_collector_pid), do: ast_fragment
end

defmodule AliasFormatter.DefmoduleSubstitute.AliasSubstitute do
  alias AliasFormatter.ContextAliasCollector

  def substitute(
        {:alias, _, [{:__aliases__, _, name_path}]},
        alias_collector_pid
      ) do
    alias_as = List.last(name_path)

    alias_collector_pid
    |> ContextAliasCollector.add_alias({name_path, alias_as})
  end

  def substitute(
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

  def substitute(
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

  def substitute(ast_fragment, _alias_collector_pid), do: ast_fragment
end

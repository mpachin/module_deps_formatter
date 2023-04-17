defmodule AliasFormatter.AST.File do
  alias AliasFormatter.AST.Alias
  alias AliasFormatter.AST.Defmodule
  alias AliasFormatter.ContextAliasCollector

  def substitute({:alias, _, _} = alias_ast) do
    alias_collector_pid = ContextAliasCollector.start_link([])

    [alias_ast]
    |> Alias.retrieve_aliases_from_ast(alias_collector_pid)

    {:__block__, [], []}
  end

  def substitute({:__block__, [], ast_content_list}) do
    alias_collector_pid = ContextAliasCollector.start_link([])

    ast_content_list
    |> Alias.retrieve_aliases_from_ast(alias_collector_pid)
    |> Enum.map(&Defmodule.substitute(&1, alias_collector_pid))
    |> then(&{:__block__, [], &1})
  end
end

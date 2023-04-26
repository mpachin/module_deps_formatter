defmodule AliasFormatter.AST.File do
  alias AliasFormatter.AST.Alias
  alias AliasFormatter.AST.Defmodule
  alias AliasFormatter.ContextAliasCollector

  def substitute({:__block__, [], ast_content_list}),
    do: process_file(ast_content_list)

  def substitute(single_content_ast),
    do: process_file([single_content_ast])

  defp process_file(ast_content_list) do
    alias_collector_pid = ContextAliasCollector.start_link()

    ast_without_aliases =
      ast_content_list
      |> Alias.retrieve_aliases_from_ast(alias_collector_pid)

    {result_context_aliases, alias_collector_state} =
      Alias.get_result_context_aliases(alias_collector_pid)

    processed_ast =
      ast_without_aliases
      |> Enum.map(fn content_ast ->
        Defmodule.substitute(content_ast, alias_collector_state)
      end)

    {:__block__, [], result_context_aliases ++ processed_ast}
  end
end

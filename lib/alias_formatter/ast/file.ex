defmodule AliasFormatter.AST.File do
  alias AliasFormatter.AST.Alias
  alias AliasFormatter.AST.Defmodule
  alias AliasFormatter.ContextAliasCollector

  def substitute({:alias, _, _} = alias_ast),
    do: process_file([alias_ast])

  def substitute({:__block__, [], ast_content_list}),
    do: process_file(ast_content_list)

  defp process_file(ast_content_list) do
    alias_collector_pid = get_alias_collector_pid()

    processed_ast =
      ast_content_list
      |> Alias.retrieve_aliases_from_ast(alias_collector_pid)
      |> Enum.map(fn content_ast ->
        # TODO: move its creation into AST.Defmodule
        content_level_pid = get_alias_collector_pid()
        Defmodule.substitute(content_ast, content_level_pid)
      end)

    result_context_aliases = Alias.get_result_context_aliases(alias_collector_pid)

    {:__block__, [], result_context_aliases ++ processed_ast}
  end

  defp get_alias_collector_pid do
    ContextAliasCollector.start_link([])
  end
end

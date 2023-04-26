defmodule AliasFormatter.AST.Defmodule do
  alias AliasFormatter.AST.Alias
  alias AliasFormatter.AST.Def
  alias AliasFormatter.ContextAliasCollector

  def substitute(
        {:defmodule, defmodule_options,
         [
           defmodule_alias,
           [
             {
               {:__block__, _, [:do]},
               {:__block__, _, content_ast_list}
             }
           ]
         ]},
        previous_context_aliases
      ) do
    process_defmodule(
      defmodule_options,
      defmodule_alias,
      content_ast_list,
      previous_context_aliases
    )
  end

  def substitute(
        {:defmodule, defmodule_options,
         [
           defmodule_alias,
           [
             {
               {:__block__, _, [:do]},
               single_content_ast
             }
           ]
         ]},
        previous_context_aliases
      ) do
    process_defmodule(
      defmodule_options,
      defmodule_alias,
      [single_content_ast],
      previous_context_aliases
    )
  end

  def substitute(
        {:defmodule, defmodule_options,
         [
           defmodule_alias,
           [do: {:__block__, _, content_ast_list}]
         ]},
        previous_context_aliases
      ) do
    process_defmodule(
      defmodule_options,
      defmodule_alias,
      content_ast_list,
      previous_context_aliases
    )
  end

  def substitute(ast_fragment, _previous_context_aliases), do: ast_fragment

  defp process_defmodule(
         defmodule_options,
         defmodule_alias,
         content_ast_list,
         previous_context_aliases
       ) do
    alias_collector_pid = ContextAliasCollector.start_link(previous_context_aliases)

    processed_content_ast_list = process_content_ast(content_ast_list, alias_collector_pid)

    {result_context_aliases, _alias_collector_state} =
      Alias.get_result_context_aliases(alias_collector_pid)

    processed_ast = result_context_aliases ++ processed_content_ast_list

    {:defmodule, defmodule_options,
     [
       defmodule_alias,
       [do: {:__block__, [], processed_ast}]
     ]}
  end

  defp process_content_ast({:alias, _, _} = alias_ast, alias_collector_pid) do
    [alias_ast]
    |> Alias.retrieve_aliases_from_ast(alias_collector_pid)
  end

  defp process_content_ast(content_ast, alias_collector_pid) do
    content_ast
    |> Alias.retrieve_aliases_from_ast(alias_collector_pid)
    |> Enum.map(&Def.substitute(&1, alias_collector_pid))
  end
end

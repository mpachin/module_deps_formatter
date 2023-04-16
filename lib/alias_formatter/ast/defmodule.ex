defmodule AliasFormatter.AST.Defmodule do
  alias AliasFormatter.AST.Alias
  alias AliasFormatter.AST.Def

  def substitute(
        {:defmodule, defmodule_options,
         [
           defmodule_alias,
           [
             {
               {:__block__, _, [:do]},
               {:__block__, _, content_ast}
             }
           ]
         ]},
        alias_collector_pid
      ) do
    process_defmodule(defmodule_options, defmodule_alias, content_ast, alias_collector_pid)
  end

  def substitute(
        {:defmodule, defmodule_options,
         [
           defmodule_alias,
           [do: {:__block__, _, content_ast}]
         ]},
        alias_collector_pid
      ) do
    process_defmodule(defmodule_options, defmodule_alias, content_ast, alias_collector_pid)
  end

  def substitute(ast_fragment, _alias_collector_pid), do: ast_fragment

  defp process_defmodule(defmodule_options, defmodule_alias, content_ast, alias_collector_pid) do
    processed_content_ast_list = process_content_ast(content_ast, alias_collector_pid)

    {:defmodule, defmodule_options,
     [
       defmodule_alias,
       [do: {:__block__, [], processed_content_ast_list}]
     ]}
  end

  defp process_content_ast({:alias, _, _} = alias_ast, alias_collector_pid) do
    Alias.substitute(alias_ast, alias_collector_pid)

    []
  end

  defp process_content_ast(content_ast, alias_collector_pid) do
    content_ast
    |> Alias.retrieve_aliases_from_ast(alias_collector_pid)
    |> Enum.map(&Def.substitute(&1, alias_collector_pid))
  end
end

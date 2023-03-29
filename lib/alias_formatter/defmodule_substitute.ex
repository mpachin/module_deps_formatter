defmodule AliasFormatter.DefmoduleSubstitute do
  alias AliasFormatter.AliasSubstitute
  alias AliasFormatter.DefSubstitute

  def substitute(
        {:defmodule, defmodule_options,
         [
           defmodule_alias,
           [
             {
               {:__block__, _, [:do]},
               content_ast
             }
           ]
         ]}
      ) do
    processed_content_ast_list = process_content_ast(content_ast)

    {:defmodule, defmodule_options,
     [
       defmodule_alias,
       [do: {:__block__, [], processed_content_ast_list}]
     ]}
  end

  def substitute(ast_fragment), do: ast_fragment

  defp process_content_ast({:__block__, _, do_block_ast_list}) do
    do_block_ast_list |> Enum.map(&DefSubstitute.substitute/1)
  end

  defp process_content_ast({:alias, _, _} = alias_ast) do
    alias_ast
    |> AliasSubstitute.substitute()
    |> Enum.map(fn {_, opts, _} = alias_ast ->
      {:alias, opts, [alias_ast]}
    end)
  end
end

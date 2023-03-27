defmodule AliasFormatter do
  @moduledoc """
  Documentation for `AliasFormatter`.
  """

  alias AliasFormatter.DefmoduleSubstitute

  @behaviour Mix.Tasks.Format

  def features(_opts) do
    [extensions: [".ex", ".exs"]]
  end

  def format(contents, _opts) do
    contents
    |> Code.string_to_quoted!(
      literal_encoder: fn literal, literal_metadata ->
        {:ok, {:__block__, literal_metadata, [literal]}}
      end
    )
    |> DefmoduleSubstitute.substitute()
    |> then(fn {:defmodule, _, defmodule_ast} ->
      defmodule_ast
      |> Enum.at(1)
      |> Keyword.fetch!(:do)
      |> then(fn {_, _, a} -> a end)
      |> split_aliases()
      |> then(fn {aliases_ast_list, rest_ast_list} ->
        aliases_ast_list
        |> sort_aliases_ast_list()
        |> Enum.concat(rest_ast_list)
      end)
      |> combine_ast(defmodule_ast)
      |> Macro.to_string()
    end)
  end

  defp split_aliases(do_block_ast_list) do
    do_block_ast_list
    |> Enum.split_with(fn
      {:alias, _, _} -> true
      _ -> false
    end)
  end

  defp sort_aliases_ast_list(aliases_ast_list) do
    aliases_ast_list
    |> Enum.sort(fn alias_ast_1, alias_ast_2 ->
      [alias_str_1, alias_str_2] =
        [alias_ast_1, alias_ast_2]
        |> Enum.map(fn {_, _, alias_ast} -> alias_ast end)
        |> Enum.map(fn [{_, _, alias_ast}] -> alias_ast end)
        |> Enum.map(&Enum.join(&1, "."))

      alias_str_1 < alias_str_2
    end)
  end

  defp combine_ast(sorted_do_ast_list, defmodule_ast) do
    updated_do_block =
      defmodule_ast
      |> Enum.at(1)
      |> Keyword.fetch!(:do)
      |> then(fn {type, opts, _ast} ->
        {type, opts, sorted_do_ast_list}
      end)

    {:defmodule, [line: 1], [List.first(defmodule_ast), [do: updated_do_block]]}
  end
end

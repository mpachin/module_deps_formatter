defmodule AliasFormatter.AliasDeduplicate do
  def deduplicate(ast_list) when is_list(ast_list) do
    {_, result_ast_list} =
      ast_list
      |> Enum.reduce({[], []}, &deduplicate_reducer/2)

    result_ast_list
  end

  def deduplicate(ast_fragment), do: ast_fragment

  defp deduplicate_reducer(
         {:alias, _, alias_ast_block_list} = alias_ast,
         {unique_alias_names, result_ast_list} = acc
       ) do
    alias_name =
      alias_ast_block_list
      |> List.first()
      |> then(fn {:__aliases__, _, name_atoms_list} ->
        name_atoms_list
      end)
      |> Enum.join()

    if alias_name in unique_alias_names do
      acc
    else
      {
        [alias_name | unique_alias_names],
        result_ast_list ++ [alias_ast]
      }
    end
  end

  defp deduplicate_reducer(
         ast_fragment,
         {unique_alias_names, result_ast_list}
       ) do
    {unique_alias_names, result_ast_list ++ [ast_fragment]}
  end
end

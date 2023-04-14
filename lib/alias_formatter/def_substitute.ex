defmodule AliasFormatter.DefSubstitute do
  alias AliasFormatter.AST

  def substitute({
        :def,
        def_options,
        [
          function_ast,
          [
            {
              {
                :__block__,
                do_block_options,
                [:do]
              },
              {:__block__, second_block_options, second_block_ast}
            }
          ]
        ]
      }) do
    {alias_pairs, updated_ast_block} = retrieve_aliases(second_block_ast)

    do_block_options
    |> Keyword.get(:format)
    |> case do
      :keyword ->
        {
          :def,
          def_options,
          [
            function_ast,
            [
              {
                {
                  :__block__,
                  do_block_options,
                  [:do]
                },
                {:__block__, second_block_options, updated_ast_block}
              }
            ]
          ]
        }

      _ ->
        unwrapped_ast = unwrap_ast(updated_ast_block)

        {:def, def_options, [function_ast, [do: unwrapped_ast]]}
    end
    |> then(&{alias_pairs, &1})
  end

  def substitute(ast_fragment), do: {[], ast_fragment}

  def unwrap_ast([expr]) when not is_list(expr) and not is_tuple(expr),
    do: expr

  def unwrap_ast([]), do: nil

  def unwrap_ast(ast_block), do: ast_block

  defp retrieve_aliases(ast_block) do
    {alias_asts_list, rest_asts_list} = AST.split_aliases(ast_block)

    alias_pairs = alias_asts_to_pairs(alias_asts_list)

    {alias_pairs, rest_asts_list}
  end

  defp alias_asts_to_pairs(alias_asts_list) do
    alias_asts_list
    |> Enum.map(&alias_ast_to_pair/1)
  end

  defp alias_ast_to_pair({:alias, _, [{:__aliases__, _, name_path}]}) do
    alias_as = List.last(name_path)
    {name_path, alias_as}
  end

  defp alias_ast_to_pair(
         {:alias, _,
          [
            {:__aliases__, _, name_path},
            [
              {{:__block__, _, [:as]}, {:__aliases__, _, alias_as}}
            ]
          ]}
       ) do
    {name_path, alias_as}
  end
end

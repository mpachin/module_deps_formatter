defmodule AliasFormatter.KeywordSubstitute do
  def substitute(
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
                {:__block__, _, [second_block_ast]}
              }
            ]
          ]
        } = ast_fragment
      ) do
    do_block_options
    |> Keyword.get(:format)
    |> case do
      :keyword -> ast_fragment
      _ -> {:def, def_options, [function_ast, [do: second_block_ast]]}
    end
  end

  def substitute(ast_fragment), do: ast_fragment
end

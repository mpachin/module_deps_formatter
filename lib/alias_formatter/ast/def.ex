defmodule AliasFormatter.AST.Def do
  alias AliasFormatter.AST.Alias

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
                {:__block__, second_block_options, second_block_ast}
              }
            ]
          ]
        },
        alias_collector_pid
      ) do
    updated_ast_block = Alias.retrieve_aliases_from_ast(second_block_ast, alias_collector_pid)

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
  end

  def substitute(ast_fragment, _alias_collector_pid), do: ast_fragment

  defp unwrap_ast([expr]) when not is_list(expr) and not is_tuple(expr),
    do: expr

  defp unwrap_ast([]), do: nil

  defp unwrap_ast([{:__block__, _, content_ast}]), do: unwrap_ast(content_ast)

  defp unwrap_ast(ast_block), do: ast_block
end

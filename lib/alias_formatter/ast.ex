defmodule AliasFormatter.AST do
  def split_aliases(do_block_ast_list) do
    do_block_ast_list
    |> Enum.split_with(fn
      {:alias, _, _} -> true
      _ -> false
    end)
  end
end

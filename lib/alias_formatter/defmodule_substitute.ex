defmodule AliasFormatter.DefmoduleSubstitute do
  alias AliasFormatter.KeywordSubstitute

  def substitute(
        {:defmodule, defmodule_options,
         [
           defmodule_alias,
           [
             {
               {:__block__, _, [:do]},
               {:__block__, [], do_block_ast_list}
             }
           ]
         ]}
      ) do
    processed_do_block_ast_list = do_block_ast_list |> Enum.map(&KeywordSubstitute.substitute/1)

    {:defmodule, defmodule_options,
     [
       defmodule_alias,
       [do: {:__block__, [], processed_do_block_ast_list}]
     ]}
  end

  def substitute(ast_fragment), do: ast_fragment
end

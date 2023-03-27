defmodule AliasFormatter.DefmoduleSubstitute do
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
    {:defmodule, defmodule_options,
     [
       defmodule_alias,
       [do: {:__block__, [], do_block_ast_list}]
     ]}
  end

  def substitute(ast_fragment), do: ast_fragment
end

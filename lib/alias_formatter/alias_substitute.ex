defmodule AliasFormatter.AliasSubstitute do
  def substitute({
        :alias,
        _,
        [
          {
            {
              :.,
              _,
              [
                {
                  :__aliases__,
                  _,
                  module_name_atoms
                },
                :{}
              ]
            },
            _,
            alias_postfixes_list
          }
        ]
      }) do
    alias_postfixes_list
    |> Enum.map(fn {:__aliases__, alias_options, alias_postfix} ->
      {:__aliases__, alias_options, module_name_atoms ++ alias_postfix}
    end)
  end

  def substitute(ast_fragment), do: ast_fragment
end

defmodule AliasFormatter do
  @moduledoc """
  Documentation for `AliasFormatter`.
  """

  alias AliasFormatter.AST.File

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
    |> File.substitute()
    |> Macro.to_string()
  end
end

defmodule AliasFormatter.ContextAliasCollector.NamePathsMap do
  def add_alias(
        {%{} = paths_to_leaf, %{} = _, %{} = _} = state,
        {name_path, alias_as}
      )
      when is_list(name_path) do
    if Map.has_key?(paths_to_leaf, name_path) do
      state
    else
      populate_map_with_alias(name_path, alias_as, state)
    end
  end

  defp populate_map_with_alias(
         name_path,
         alias_as,
         {
           paths_to_leaf,
           leaf_to_path,
           leaf_to_increment
         }
       ) do
    {updated_name, updated_leaf_to_increment} = update_names(leaf_to_increment, alias_as)

    {
      paths_to_leaf |> Map.put(name_path, updated_name),
      leaf_to_path |> Map.put(updated_name, name_path),
      updated_leaf_to_increment
    }
  end

  defp update_names(leaf_to_increment, atom_name) do
    atom_name
    |> Atom.to_string()
    |> String.split("_")
    |> case do
      [string_name] ->
        {string_name, 1}

      splitted_name_list ->
        get_name_and_increment(splitted_name_list)
    end
    |> update_name_and_leaf_to_increment(leaf_to_increment)
  end

  defp get_name_and_increment(splitted_name_list) do
    {postfix, rest_name_list} = List.pop_at(splitted_name_list, -1)

    postfix
    |> get_postfix_increment()
    |> case do
      {:ok, increment} ->
        {rest_name_list, increment}

      {:error, increment} ->
        {splitted_name_list, increment}
    end
    |> then(fn {name_list, increment} ->
      {Enum.join(name_list, "_"), increment}
    end)
  end

  defp get_postfix_increment(postfix) do
    try do
      int_postfix = String.to_integer(postfix)
      {:ok, int_postfix}
    rescue
      _ -> {:error, 2}
    end
  end

  defp update_name_and_leaf_to_increment({string_name, postfix_increment}, leaf_to_increment) do
    atom_name = string_name |> String.to_atom()

    leaf_to_increment
    |> Map.get(atom_name)
    |> case do
      nil ->
        postfix_increment

      current_increment ->
        if current_increment >= postfix_increment do
          current_increment + 1
        else
          postfix_increment
        end
    end
    |> prepare_name_and_leaf_to_increment(leaf_to_increment, string_name, atom_name)
  end

  defp prepare_name_and_leaf_to_increment(
         result_increment,
         leaf_to_increment,
         string_name,
         atom_name
       ) do
    updated_leaf_to_increment = leaf_to_increment |> Map.put(atom_name, result_increment)

    updated_name =
      result_increment
      |> case do
        1 -> string_name
        increment -> "#{string_name}_#{increment}"
      end
      |> String.to_atom()

    {updated_name, updated_leaf_to_increment}
  end
end

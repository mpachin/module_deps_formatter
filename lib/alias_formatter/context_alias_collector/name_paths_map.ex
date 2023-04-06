defmodule AliasFormatter.ContextAliasCollector.NamePathsMap do
  def add_alias(
        {%{} = paths_to_leaf, %{} = leaf_to_increment, %{} = leaf_to_path} = state,
        {name_path, alias_as}
      )
      when is_list(name_path) do
    if path_already_presented?(paths_to_leaf, name_path) do
      state
    else
      {updated_leaf, updated_paths_to_leaf, updated_leaf_to_increment} =
        populate_map_with_alias(name_path, paths_to_leaf, alias_as, leaf_to_increment)

      updated_leaf_to_path = leaf_to_path |> Map.put(updated_leaf, name_path)

      {updated_paths_to_leaf, updated_leaf_to_increment, updated_leaf_to_path}
    end
  end

  defp path_already_presented?(paths_to_leaf, name_path) do
    paths_to_leaf
    |> get_in(name_path)
    |> case do
      nil ->
        false

      _ ->
        true
    end
  end

  defp populate_map_with_alias([last_module_name], paths_to_leaf, alias_as, leaf_to_increment) do
    {updated_name, updated_leaf_to_increment} = update_names(leaf_to_increment, alias_as)

    paths_to_leaf
    |> Map.put(last_module_name, updated_name)
    |> then(&{updated_name, &1, updated_leaf_to_increment})
  end

  defp populate_map_with_alias(
         [atom_module_name | rest_atom_name_list],
         paths_to_leaf,
         alias_as,
         leaf_to_increment
       ) do
    nested_paths_map =
      paths_to_leaf
      |> Map.get(atom_module_name)
      |> case do
        nil -> %{}
        nested_state_map -> nested_state_map
      end

    {updated_name, updated_nested_paths_map, updated_leaf_to_increment} =
      populate_map_with_alias(rest_atom_name_list, nested_paths_map, alias_as, leaf_to_increment)

    paths_to_leaf
    |> Map.put(atom_module_name, updated_nested_paths_map)
    |> then(&{updated_name, &1, updated_leaf_to_increment})
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

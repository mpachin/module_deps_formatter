defmodule AliasFormatter.ContextAliasCollector.NamePathsMap do
  def add_alias({%{} = name_paths_map, %{} = used_names}, {name_path, alias_as})
      when is_list(name_path) do
    populate_state_with_alias(name_path, name_paths_map, alias_as, used_names)
  end

  defp populate_state_with_alias([last_module_name], name_paths_map, alias_as, used_names) do
    {updated_name, updated_used_names} = update_names(alias_as, used_names)

    name_paths_map
    |> Map.put(last_module_name, updated_name)
    |> then(&{&1, updated_used_names})
  end

  defp populate_state_with_alias(
         [atom_module_name | rest_atom_name_list],
         name_paths_map,
         alias_as,
         used_names
       ) do
    nested_paths_map =
      name_paths_map
      |> Map.get(atom_module_name)
      |> case do
        nil -> %{}
        nested_state_map -> nested_state_map
      end

    {updated_nested_paths_map, updated_used_names} =
      populate_state_with_alias(rest_atom_name_list, nested_paths_map, alias_as, used_names)

    name_paths_map
    |> Map.put(atom_module_name, updated_nested_paths_map)
    |> then(&{&1, updated_used_names})
  end

  defp update_names(atom_name, used_names) do
    if Map.has_key?(used_names, atom_name) do
      {updated_name, updated_increment} =
        used_names
        |> Map.get(atom_name)
        |> increment_postfix(atom_name)

      {updated_name, Map.put(used_names, atom_name, updated_increment)}
    else
      {atom_name, Map.put(used_names, atom_name, 1)}
    end
  end

  defp increment_postfix(increment, atom_name) do
    atom_name
    |> Atom.to_string()
    |> String.split("_")
    |> case do
      [string_name] ->
        updated_increment = increment + 1
        {"#{string_name}_#{updated_increment}", updated_increment}

      splitted_name_list ->
        {postfix, rest_name_list} = List.pop_at(splitted_name_list, -1)

        postfix
        |> increment_str_postfix()
        |> case do
          {:ok, incremented_postfix} ->
            {rest_name_list ++ [incremented_postfix], incremented_postfix}

          {:error, new_postfix} ->
            {splitted_name_list ++ [new_postfix], new_postfix}
        end
        |> then(fn {name_list, increment} ->
          {Enum.join(name_list, "_"), increment}
        end)
    end
    |> then(fn {string_name, increment} ->
      {String.to_atom(string_name), increment}
    end)
  end

  defp increment_str_postfix(postfix) do
    try do
      int_postfix = String.to_integer(postfix)
      {:ok, int_postfix + 1}
    rescue
      _ -> {:error, 2}
    end
  end
end

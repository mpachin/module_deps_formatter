defmodule AliasFormatter.ContextAliasCollector.NamePathsMap do
  def add_alias({%{} = name_paths_map, %{} = used_names}, {name_path, alias_as})
      when is_list(name_path) do
    if path_already_presented?(name_paths_map, name_path) do
      {name_paths_map, used_names}
    else
      populate_map_with_alias(name_path, name_paths_map, alias_as, used_names)
    end
  end

  defp path_already_presented?(name_paths_map, name_path) do
    name_paths_map
    |> get_in(name_path)
    |> case do
      nil ->
        false

      _ ->
        true
    end
  end

  defp populate_map_with_alias([last_module_name], name_paths_map, alias_as, used_names) do
    {updated_name, updated_used_names} = update_names(used_names, alias_as)

    name_paths_map
    |> Map.put(last_module_name, updated_name)
    |> then(&{&1, updated_used_names})
  end

  defp populate_map_with_alias(
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
      populate_map_with_alias(rest_atom_name_list, nested_paths_map, alias_as, used_names)

    name_paths_map
    |> Map.put(atom_module_name, updated_nested_paths_map)
    |> then(&{&1, updated_used_names})
  end

  defp update_names(used_names, atom_name) do
    atom_name
    |> Atom.to_string()
    |> String.split("_")
    |> case do
      [string_name] ->
        {string_name, 1}

      splitted_name_list ->
        get_name_and_increment(splitted_name_list)
    end
    |> update_name_and_used_names(used_names)
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

  defp update_name_and_used_names({string_name, postfix_increment}, used_names) do
    atom_name = string_name |> String.to_atom()

    used_names
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
    |> prepare_name_and_used_names(used_names, string_name, atom_name)
  end

  defp prepare_name_and_used_names(result_increment, used_names, string_name, atom_name) do
    updated_used_names = used_names |> Map.put(atom_name, result_increment)

    updated_name =
      result_increment
      |> case do
        1 -> string_name
        increment -> "#{string_name}_#{increment}"
      end
      |> String.to_atom()

    {updated_name, updated_used_names}
  end
end

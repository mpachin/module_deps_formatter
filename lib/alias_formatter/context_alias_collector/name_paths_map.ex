defmodule AliasFormatter.ContextAliasCollector.NamePathsMap do
  def add_alias(%{} = name_paths_map, {name_path, alias_as}) do
    populate_state_with_alias(name_path, name_paths_map, alias_as)
  end

  defp populate_state_with_alias([last_module_name], name_paths_map, alias_as) do
    Map.put(name_paths_map, last_module_name, alias_as)
  end

  defp populate_state_with_alias(
         [atom_module_name | rest_atom_name_list],
         name_paths_map,
         alias_as
       ) do
    nested_paths_map =
      name_paths_map
      |> Map.get(atom_module_name)
      |> case do
        nil -> %{}
        nested_state_map -> nested_state_map
      end

    updated_nested_paths_map =
      populate_state_with_alias(rest_atom_name_list, nested_paths_map, alias_as)

    Map.put(name_paths_map, atom_module_name, updated_nested_paths_map)
  end
end

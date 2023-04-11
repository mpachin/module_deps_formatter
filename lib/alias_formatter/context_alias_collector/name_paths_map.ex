defmodule AliasFormatter.ContextAliasCollector.NamePathsMap do
  def add_alias(
        {%{} = paths_to_leaf, %{} = leaf_to_path, %{} = leaf_to_increment} = state,
        {name_path, alias_as} = alias_data
      )
      when is_list(name_path) do
    if Map.has_key?(paths_to_leaf, name_path) do
      if Map.has_key?(leaf_to_path, alias_as) do
        state
      else
        {
          paths_to_leaf,
          leaf_to_path |> Map.put(alias_as, name_path),
          leaf_to_increment
        }
      end
    else
      populate_map_with_alias(state, alias_data)
    end
  end

  def get_alias_short_form(
        {%{} = paths_to_leaf, %{} = leaf_to_path, _} = state,
        name_path
      ) do
    paths_to_leaf
    |> Map.get(name_path)
    |> case do
      nil ->
        full_name_path = get_full_name_path(name_path, leaf_to_path)

        paths_to_leaf
        |> Map.get(full_name_path)
        |> case do
          nil ->
            last_name = List.last(full_name_path)

            updated_state = add_alias(state, {full_name_path, last_name})

            updated_name = get_updated_name(updated_state, last_name)

            {updated_name, updated_state}

          alias_as ->
            {alias_as, state}
        end

      alias_as ->
        {alias_as, state}
    end
  end

  defp get_updated_name({_, _, %{} = leaf_to_increment}, name) do
    {
      incrementless_name,
      _original_postfix_is_ignored
    } = split_increment(name)

    leaf_to_increment
    |> Map.get(incrementless_name)
    |> case do
      1 ->
        incrementless_name

      increment ->
        incrementless_name
        |> Atom.to_string()
        |> then(&"#{&1}_#{increment}")
        |> String.to_atom()
    end
  end

  defp get_full_name_path(name_path, leaf_to_path) do
    {first_name, rest_name_path} = name_path |> List.pop_at(0)

    {
      root_name,
      _original_postfix_is_ignored
    } = split_increment(first_name)

    leaf_to_path
    |> Map.get(root_name)
    |> case do
      nil ->
        name_path

      full_path_before ->
        full_path_before ++ rest_name_path
    end
  end

  defp populate_map_with_alias(
         {
           paths_to_leaf,
           leaf_to_path,
           leaf_to_increment
         },
         {name_path, alias_as}
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
    |> split_increment()
    |> update_name_and_leaf_to_increment(leaf_to_increment)
  end

  defp split_increment(atom_name) do
    atom_name
    |> Atom.to_string()
    |> String.split("_")
    |> case do
      [string_name] ->
        {string_name, 1}

      splitted_name_list ->
        get_name_and_increment(splitted_name_list)
    end
    |> then(fn {string_name, increment} ->
      {String.to_atom(string_name), increment}
    end)
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

  defp update_name_and_leaf_to_increment({atom_name, postfix_increment}, leaf_to_increment) do
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
    |> prepare_name_and_leaf_to_increment(leaf_to_increment, atom_name)
  end

  defp prepare_name_and_leaf_to_increment(
         result_increment,
         leaf_to_increment,
         atom_name
       ) do
    updated_leaf_to_increment = leaf_to_increment |> Map.put(atom_name, result_increment)
    string_name = Atom.to_string(atom_name)

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

defmodule AliasFormatter.ContextAliasCollector do
  use GenServer

  alias AliasFormatter.ContextAliasCollector.NamePathsMap

  def start_link(previous_context_aliases \\ {%{}, %{}, %{}}) do
    {:ok, pid} = GenServer.start_link(__MODULE__, previous_context_aliases)
    pid
  end

  def add_alias(pid, {name_path, alias_as} = alias_data)
      when is_pid(pid) and is_list(name_path) and is_atom(alias_as) do
    GenServer.cast(pid, {:add_alias, alias_data})
  end

  def get_short_name(pid, name_path) when is_pid(pid) and is_list(name_path) do
    GenServer.call(pid, {:get_short_name, name_path})
  end

  def get_result_aliases(pid) when is_pid(pid) do
    GenServer.call(pid, :get_result_aliases)
  end

  @impl true
  def init({%{} = initial_paths_to_leaf, %{}, %{}} = init_state) do
    {:ok, {init_state, initial_paths_to_leaf}}
  end

  @impl true
  def handle_cast({:add_alias, alias_data}, {state, initial_paths_to_leaf}) do
    state
    |> NamePathsMap.add_alias(alias_data)
    |> then(&{:noreply, {&1, initial_paths_to_leaf}})
  end

  @impl true
  def handle_call({:get_short_name, name_path}, _from, {state, initial_paths_to_leaf}) do
    state
    |> NamePathsMap.get_alias_short_form(name_path)
    |> then(fn {short_name, updated_state} ->
      {:reply, short_name, {updated_state, initial_paths_to_leaf}}
    end)
  end

  @impl true
  def handle_call(
        :get_result_aliases,
        _from,
        {{paths_to_leaf, _, _} = state, initial_paths_to_leaf}
      ) do
    paths_to_leaf
    |> remove_previous_context_aliases(initial_paths_to_leaf)
    |> paths_to_sorted_list()
    |> then(&{:stop, :normal, {&1, state}, {state, initial_paths_to_leaf}})
  end

  defp remove_previous_context_aliases(paths_to_leaf, initial_paths_to_leaf) do
    paths_to_leaf
    |> Map.reject(fn {name_path, _} ->
      Map.has_key?(initial_paths_to_leaf, name_path)
    end)
  end

  defp paths_to_sorted_list(paths_to_leaf) do
    paths_to_leaf
    |> Enum.sort(fn {name_path_1, _}, {name_path_2, _} ->
      Enum.join(name_path_1) <= Enum.join(name_path_2)
    end)
  end
end

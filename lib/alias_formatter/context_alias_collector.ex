defmodule AliasFormatter.ContextAliasCollector do
  use GenServer

  alias AliasFormatter.ContextAliasCollector.NamePathsMap

  def add_alias(pid, {name_path, alias_as} = alias_data)
      when is_list(name_path) and is_atom(alias_as) do
    GenServer.cast(pid, {:add_alias, alias_data})
  end

  def get_short_name(pid, name_path) when is_list(name_path) do
    GenServer.call(pid, {:get_short_name, name_path})
  end

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    pid
  end

  @impl true
  def init(_) do
    paths_to_leaf = %{}
    leaf_to_path = %{}
    leaf_to_increment = %{}
    {:ok, {paths_to_leaf, leaf_to_path, leaf_to_increment}}
  end

  @impl true
  def handle_cast({:add_alias, alias_data}, state) do
    state
    |> NamePathsMap.add_alias(alias_data)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_call({:get_short_name, name_path}, _from, state) do
    state
    |> NamePathsMap.get_alias_short_form(name_path)
    |> then(fn {short_name, updated_state} ->
      {:reply, short_name, updated_state}
    end)
  end
end

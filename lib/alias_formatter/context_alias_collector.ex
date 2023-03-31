defmodule AliasFormatter.ContextAliasCollector do
  use GenServer

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    pid
  end

  def add_alias_data(pid, {_, _} = alias_data) do
    GenServer.cast(pid, {:add_alias, alias_data, alias_data})
  end

  def add_alias_data(pid, {_, _} = was, {_, _} = now) do
    GenServer.cast(pid, {:add_alias, was, now})
  end

  def get_short_name(pid, module_atoms_name) when is_list(module_atoms_name) do
    GenServer.call(pid, {:get_short_name})
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:add_alias, {alias_atoms_name, alias_as}}, state) do
    state
    |> Map.put(alias_atoms_name, alias_as)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_call({:get_short_name, alias_atoms_name}, _from, state) do
    state
    |> Map.get(alias_atoms_name)
    |> then(&{:reply, &1, state})
  end
end

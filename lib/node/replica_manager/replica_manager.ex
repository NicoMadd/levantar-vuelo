defmodule Replica.Manager do
  use GenServer

  @heartbeat_delay 5000

  @doc """
  init define
  - un timestamp para indicar prioridad sobre cada nodo llamado identifier.
  - el master actual
  - los neighbours a los que esta conectado. [{node, nb_timestamp}]
  """
  def init(_args) do
    # Get timestamp for identifier
    identifier = Ksuid.generate()
    IO.puts(identifier)

    {:ok, {identifier, {[]}}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  
  Neighbour: {node, nb_timestamp}
  """
  def handle_call({:add_neighbour, neighbour_node}, _from, {identifier, neighbours}) do
    {:reply, :ok, {identifier, [neighbour_node | neighbours]}}
  end

  def handle_call({:remove_neighbour, neighbour_node}, _from, {identifier, neighbours}) do
    {:reply, :ok, {identifier, List.delete(neighbours, neighbour_node)}}
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  # Client functions

  @doc """
  Add a new neighbor
  Neighbour: {node, nb_timestamp}
  """
  def add_neighbor(pid, neighbour_node) do
    GenServer.call(pid, {:add_neighbour, neighbour_node})
  end

  @doc """
  Remove a neighbour
  """
  def remove_neighbor(pid, neighbour_node) do
    GenServer.call(pid, {:remove_neighbour, neighbour_node})
  end

  # Private functions
end

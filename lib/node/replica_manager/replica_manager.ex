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

    IO.puts(
      "Nodo " <> Atom.to_string(Node.self()) <> " levantado con identificador " <> identifier
    )

    {:ok, {identifier, {identifier, []}}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  
  Neighbour: {node, nb_identifier}
  """
  def handle_call({:add_neighbour, new_neighbour}, _from, {identifier, {_old_master, neighbours}}) do
    # Check if node is the new master ordering the identifier
    master = select_master(identifier, new_neighbour, neighbours)

    if(master == identifier) do
      IO.puts("Este nodo es el elegido master")
    else
      IO.puts("Nuevo master " <> master)
    end

    {:reply, :ok, {identifier, {master, [new_neighbour | neighbours]}}}
  end

  def handle_call({:remove_neighbour, fallen_node}, _from, {identifier, {master, neighbours}}) do
    new_neighbours =
      neighbours
      |> Enum.filter(fn {node, _} -> node == fallen_node end)

    {:reply, :ok, {identifier, {master, new_neighbours}}}
  end

  def handle_call(:get_identifier, _from, {identifier, context}) do
    {:reply, identifier, {identifier, context}}
  end

  def handle_call(:get_neighbours, _from, {identifier, {master, neighbours}}) do
    {:reply, neighbours, {identifier, {master, neighbours}}}
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
  Solo necesito el nodo, no es posible conseguir el identifier ya que el nodo esta caido
  """
  def remove_neighbor(pid, node) do
    GenServer.call(pid, {:remove_neighbour, node})
  end

  def get_identifier(pid) do
    GenServer.call(pid, :get_identifier)
  end

  def get_neighbours(pid) do
    GenServer.call(pid, :get_neighbours)
  end

  # Private functions

  defp select_master(own_identifier, {_node, new_identifier}, neighbours) do
    selected =
      neighbours
      |> Enum.map(fn {_node, id} -> id end)
      |> Enum.concat([new_identifier, own_identifier])
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.fetch(0)

    case selected do
      {:ok, master} -> master
      :error -> new_identifier
    end
  end
end

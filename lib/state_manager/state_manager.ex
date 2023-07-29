defmodule State.Manager do
  def start_link(_) do
    response = DeltaCrdt.start_link(DeltaCrdt.AWLWWMap, name: Node.self(), sync_interval: 20)
    State.Manager.refresh_neighbours()
    response
  end

  @doc """
  Cada neighbour basicamente se compone de el nombre del DeltaCRDT en el nodo al que invoca y ese mismo nodo
  
  `{crdt_name, node_name}`
  
  Esto es para que despues sepa a que nodo apuntar ya que cada DeltaCRDT en cada nodo es unico y nombrado segun el nombre del nodo.
  """
  def set_neighbours(crdt, neighbours) do
    DeltaCrdt.set_neighbours(crdt, neighbours)
  end

  @doc """
  Aca directamente se puede usar esta funcion sin argumentos ya que se invoca al DeltaCRDT nombrado como el nodo mismo
  y se agregan los nodos conectados al nodo en cuestion.
  """
  def refresh_neighbours() do
    neighbours =
      Node.list()
      |> Enum.map(fn n -> {n, n} end)

    State.Manager.set_neighbours(Node.self(), neighbours)
  end

  def get_state(key, retries \\ 0, default \\ nil, after_func \\ fn -> nil end) do
    State.Manager.Task.Supervisor.get_state(key, retries, default, after_func)
  end

  def save_state(key, value) do
    State.Manager.save_state(Node.self(), key, value)
  end

  def save_state(crdt, key, value) do
    DeltaCrdt.put(crdt, key, value)
  end

  def delete_state(key) do
    State.Manager.delete_state(Node.self(), key)
  end

  def delete_state(crdt, key) do
    DeltaCrdt.delete(crdt, key)
  end
end

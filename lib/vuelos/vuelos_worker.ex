defmodule Vuelos.Worker do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :vuelos_worker)
  end

  def init(_init_arg) do
    {:ok, {%{}, 1}}
  end

  # Handles

  def handle_call({:publicar, {precio, aerolinea}}, _, {vuelos, id_seq}) do
    vuelo = %{precio: precio, aerolinea: aerolinea}
    newVuelos = Map.put(vuelos, id_seq, vuelo)
    {:reply, newVuelos, {newVuelos, id_seq + 1}}
  end

  def handle_call(:get_all, _from, vuelos) do
    {:reply, vuelos, vuelos}
  end

  def handle_call({:get_precio, vuelo_id}, _from, {vuelos, id_seq}) do
    vuelo = Map.get(vuelos, vuelo_id, :none)

    case vuelo do
      %{precio: precio} -> {:reply, precio, {vuelos, id_seq}}
      _ -> {:reply, :none, {vuelos, id_seq}}
    end
  end

  # Funciones definidas para el cliente

  def publicar(pid, precio, aerolinea) do
    GenServer.call(pid, {:publicar, {precio, aerolinea}})
  end

  def get_precio(pid, vuelo_id) do
    GenServer.call(pid, {:get_precio, vuelo_id})
  end

  def get_all(pid) do
    GenServer.call(pid, :get_all)
  end

  def validar(_pid, _vuelo_id) do
    {:reply, :ok}
  end
end

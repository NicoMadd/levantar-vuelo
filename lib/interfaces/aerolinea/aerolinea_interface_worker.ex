defmodule Aerolinea.Interface.Worker do
  use GenServer
  require Logger

  @registry Aerolinea.Interface.Worker.Registry

  def start_link(aerolinea_id) do
    GenServer.start_link(__MODULE__, {:ok, aerolinea_id},
      name: {:via, Registry, {@registry, aerolinea_id}}
    )
  end

  def init({:ok, aerolinea_id}) do
    {:ok, {aerolinea_id}}
  end

  # Handles

  def handle_call({:publicar_vuelo}, _from, {aerolinea_id}) do
    vuelo_worker_name = get_worker_name(aerolinea_id)
    Vuelos.DynamicSupervisor.start_child(vuelo_worker_name)

    Logger.info("Aerolinea #{aerolinea_id} publica vuelo")

    Vuelos.Worker.publicar_vuelo(
      {:name, vuelo_worker_name},
      "Boeing",
      10,
      ~U[2023-06-18 00:00:00Z],
      "Buenos Aires",
      "Montevideo",
      3
    )

    {:reply, :ok, {aerolinea_id}}
  end

  # Cliente

  def publicar_vuelo(name) do
    case Registry.lookup(@registry, name) do
      [{pid, _}] ->
        GenServer.call(pid, {:publicar_vuelo})

      _ ->
        {:none}
    end
  end

  def publicar_vuelo_largo() do
    Logger.info("Usuario publica vuelo")

    Vuelos.Worker.publicar_vuelo(
      :vuelos_worker,
      "Boeing",
      10,
      ~U[2023-06-18 00:00:00Z],
      "Buenos Aires",
      "Montevideo",
      500
    )
  end

  # Private functions

  defp get_worker_name(aerolinea_id) do
    to_string(aerolinea_id) <> "_vuelo_worker"
  end
end

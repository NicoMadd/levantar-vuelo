defmodule Aerolinea do
  use GenServer
  require Logger

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :aerolinea_interface_worker)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  def publicar_vuelo() do
    Logger.info("Usuario publica vuelo")

    Vuelos.Worker.publicar_vuelo(
      :vuelos_worker,
      "Boeing",
      10,
      ~U[2023-06-18 00:00:00Z],
      "Buenos Aires",
      "Montevideo",
      3
    )
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
end

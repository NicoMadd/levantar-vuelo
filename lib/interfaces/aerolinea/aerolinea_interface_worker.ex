defmodule Aerolinea.Interface.Worker do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :aerolinea_interface_worker)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  def publicar_vuelo() do
    Vuelos.Worker.publicar_vuelo(
      :vuelos_worker,
      "Boeing",
      10,
      ~U[2023-06-18 00:00:00Z],
      "Buenos Aires",
      "Montevideo",
      60
    )
  end
end

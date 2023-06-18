defmodule Usuario.Interface.Worker do
  use GenServer
  require Logger

  @registry Usuario.Interface.Worker.Registry

  def start_link(usuario_id) do
    GenServer.start_link(__MODULE__, :ok, name: {:via, Registry, {@registry, usuario_id}})
  end

  def init(:ok) do
    {:ok, %{vuelos: []}}
  end

  def notificar_nuevo_vuelo(usuario_id, vuelo_id) do
    Logger.info("Notificando a usuario: " <> "#{usuario_id}" <> " por el vuelo: " <> vuelo_id)
  end

  def notificar_cierre_vuelo(usuario_id, vuelo_id) do
    Logger.info("Notificando a usuario: " <> "#{usuario_id}" <> " por el vuelo: " <> vuelo_id)
  end

  def iniciar_reserva(vuelo_id, usuario_id) do
    Logger.info(
      "Iniciando reserva para el vuelo " <> vuelo_id <> " para el usuario: #{usuario_id}"
    )

    Reservas.Worker.iniciar_reserva(:reservas_worker, vuelo_id, usuario_id)
  end

  def reservar_asientos(reserva_id, asientos) do
    Logger.info("Seleccionando #{asientos} asientos para la reserva #{reserva_id}")

    Reservas.Worker.reservar_asientos(:reservas_worker, reserva_id, asientos)
  end
end

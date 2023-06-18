defmodule Usuario.Interface.Worker do
  use GenServer
  require Logger

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :usuario_interface_worker)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  def notificar_nuevo_vuelo(usuario_id, vuelo_id) do
    Logger.info("Notificando a usuario: " <> "#{usuario_id}" <> " por el vuelo: " <> vuelo_id)
  end

  def iniciar_reserva(usuario_id, vuelo_id) do
    Logger.info(
      "Iniciando reserva para el vuelo " <> vuelo_id <> " para el usuario: #{usuario_id}"
    )

    Reservas.Worker.iniciar_reserva(:reservas_worker, vuelo_id, usuario_id)
  end
end

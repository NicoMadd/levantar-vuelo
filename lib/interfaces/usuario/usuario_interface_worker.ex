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
end

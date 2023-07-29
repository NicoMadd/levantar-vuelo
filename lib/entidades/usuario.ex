defmodule Entidades.Usuario do
  use GenServer
  require Logger

  @registry Entidades.Usuario.Registry

  def start_link(usuario_id, nombre) do
    GenServer.start_link(__MODULE__, {usuario_id, nombre},
      name: via_tuple(usuario_id)
    )
  end

  defp via_tuple(usuario_id) do
    {:via, Horde.Registry, {@registry, usuario_id}}
  end

  # child spec
  def child_spec({usuario_id, nombre}) do
    %{
      id: "#{usuario_id}",
      start: {__MODULE__, :start_link, [usuario_id, nombre]},
      type: :worker,
      restart: :transient
    }
  end

  def init({usuario_id, nombre}) do
    {:ok, {usuario_id, nombre}}
  end

  def handle_cast({:cierre_reserva, vuelo_id}, {usuario_id, nombre}) do
    info = "Notificando usuario #{usuario_id} del cierre del vuelo #{vuelo_id}."
    Logger.info(info)

    Usuario.Websocket.Handler.notificar(info, usuario_id)

    {:noreply, {usuario_id, nombre}}
  end
end

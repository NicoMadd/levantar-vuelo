defmodule Reserva do
  use GenServer
  require Logger

  @registry Reservas.Registry

  def start_link(usuario_id, vuelo_id) do
    GenServer.start_link(__MODULE__, {usuario_id, vuelo_id},
      name: {:via, Registry, {@registry, {usuario_id, vuelo_id}}}
    )
  end

  # child spec
  def child_spec({vuelo_id, info}) do
    %{
      id: "reserva#{vuelo_id}",
      start: {__MODULE__, :start_link, [vuelo_id, info]},
      type: :worker,
      restart: :transient
    }
  end

  def init({usuario_id, vuelo_id}) do
    {:ok, {usuario_id, vuelo_id}}
  end
end

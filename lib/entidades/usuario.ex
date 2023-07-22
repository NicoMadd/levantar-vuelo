defmodule Entidades.Usuario do
  use GenServer

  @registry Usuario.Registry

  def start_link(usuario_id, nombre) do
    GenServer.start_link(__MODULE__, {usuario_id, nombre},
      name: via_tuple(usuario_id)
    )
  end

  defp via_tuple(usuario_id) do
    {:via, Registry, {@registry, usuario_id}}
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
  
  def init(_args) do
    {:ok, :initial_state}
  end
end

defmodule Entidades.UsuarioRegistry do

  def start_link(_init) do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(_init_arg) do
    {:ok, []}
  end

  def find(usuario_id) do
    Registry.lookup(__MODULE__, usuario_id)
  end

end

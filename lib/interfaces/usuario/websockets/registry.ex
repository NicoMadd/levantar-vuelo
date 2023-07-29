defmodule Usuario.Websocket.Registry do
  use Horde.Registry
  require Logger

  def start_link(_init) do
    Horde.Registry.start_link(keys: :unique, name: __MODULE__)
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

  def find_usuario_pid(usuario_id) do
    case Horde.Registry.lookup(__MODULE__, usuario_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, "usuario not found"}
    end
  end

  def register(usuario_id) do
    Horde.Registry.register(__MODULE__, usuario_id, {})
  end

  # def all(function) do
  #   Registry.dispatch()
  # end

end

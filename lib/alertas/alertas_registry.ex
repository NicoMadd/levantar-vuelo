defmodule Alertas.Registry do
  use Horde.Registry
  require Logger

  def start_link(_init) do
    Horde.Registry.start_link(__MODULE__, [keys: :unique], name: __MODULE__)
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

  def init(init_arg) do
    [members: members()]
    |> Keyword.merge(init_arg)
    |> Horde.Registry.init()
  end

  defp members() do
    [Node.self() | Node.list()]
    |> Enum.map(fn node -> {__MODULE__, node} end)
  end

  def crear_alerta(alerta_id, type) do
    case Alertas.DynamicSupervisor.start_child(alerta_id, type) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, msg} -> {:error, "An error occurred: #{msg}"}
    end
  end

  def find_alerta(alerta_id) do
    case Horde.Registry.lookup(__MODULE__, alerta_id) do
      [] -> {:error, "not found"}
      _ -> {:ok, Horde.Registry.lookup(__MODULE__, alerta_id) |> List.first() |> elem(0)}
    end
  end

end

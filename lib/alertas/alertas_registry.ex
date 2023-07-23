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

  def find_or_create_alerta(alerta_id, type) do
    if alerta_exists?(alerta_id) do
      {:ok, Horde.Registry.lookup(__MODULE__, alerta_id) |> List.first() |> elem(0)}
    else
      {_, pid} = alerta_id |> Alertas.DynamicSupervisor.start_child(type)
      {:ok, pid}
    end
  end

  def alerta_exists?(alerta_id) do
    # when is_integer(alerta_id) and alerta_id >= 1 and alerta_id <= 12 do
    case Horde.Registry.lookup(__MODULE__, alerta_id) do
      [] -> false
      _ -> true
    end
  end
end

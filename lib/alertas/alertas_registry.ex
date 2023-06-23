defmodule Alertas.Registry do
  require Logger

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

  def find_or_create_alerta(alerta_id, type) do
    if alerta_exists?(alerta_id) do
      {:ok, Registry.lookup(__MODULE__, alerta_id) |> List.first() |> elem(0)}
    else
      {_, pid} = alerta_id |> Alertas.DynamicSupervisor.start_child(type)
      {:ok, pid}
    end
  end

  def alerta_exists?(alerta_id) do
    # when is_integer(alerta_id) and alerta_id >= 1 and alerta_id <= 12 do
    case Registry.lookup(__MODULE__, alerta_id) do
      [] -> false
      _ -> true
    end
  end
end

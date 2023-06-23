defmodule Reservas.Registry do
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

  def find(usuario_id, vuelo_id) do
    Registry.lookup(__MODULE__, {usuario_id, vuelo_id})
  end

  def find_reservas_by_vuelo(vuelo_id) do
    match_all = {:_, :"$1"}
    map_result = [%{id: :"$1"}]

    guards = [{:==, :"$1", vuelo_id}]
    Registry.select(__MODULE__, [{match_all, guards, map_result}])
  end
end

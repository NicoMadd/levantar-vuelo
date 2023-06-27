defmodule Vuelos.Registry do
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

  def find(vuelo_id) do
    Registry.lookup(__MODULE__, vuelo_id)
  end

  def vuelo_exists?(account_id) when is_integer(account_id) do
    case Registry.lookup(__MODULE__, account_id) do
      [] -> false
      _ -> true
    end
  end
end

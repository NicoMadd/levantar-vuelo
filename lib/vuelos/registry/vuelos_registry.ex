defmodule Vuelos.Registry do
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

  def find(vuelo_id) do
    Horde.Registry.lookup(__MODULE__, vuelo_id)
  end

  def vuelo_exists?(account_id) when is_integer(account_id) do
    case Horde.Registry.lookup(__MODULE__, account_id) do
      [] -> false
      _ -> true
    end
  end
end

defmodule Vuelos.Worker.Registry do
  require Registry

  def register(key, value) do
    Registry.register(__MODULE__, key, value)
  end

  def unregister(key) do
    Registry.unregister(__MODULE__, key)
  end

  def get(key) do
    case Registry.lookup(__MODULE__, key) do
      [{_, value}] -> {:ok, value}
      [] -> {:error, :not_found}
    end
  end
end

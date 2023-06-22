defmodule Vuelos.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(_init) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(vuelo_id) do
    # Ejemplo para agregar accounts:
    # {:ok, pid} = AccountDynamicSupervisor.start_child(1)
    spec = {Vuelo, {vuelo_id}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end

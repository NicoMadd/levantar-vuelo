defmodule Vuelos.DynamicSupervisor do
  use DynamicSupervisor
  require Logger

  def start_link(init_args) do
    DynamicSupervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(_init_arg) do
    opts = [strategy: :one_for_one]
    DynamicSupervisor.init(opts)
  end

  def start_child(worker_id) do
    spec = {Vuelos.Worker, {worker_id}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end

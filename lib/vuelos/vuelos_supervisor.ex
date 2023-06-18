defmodule Vuelos.Supervisor do
  use Supervisor

  def start_link(init) do
    Supervisor.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      Vuelos.DynamicSupervisor,
      Vuelos.DB,
      {Registry, [keys: :unique, name: Vuelos.Worker.Registry]}
    ]

    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end
end

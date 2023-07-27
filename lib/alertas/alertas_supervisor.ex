defmodule Alertas.Supervisor do
  use Supervisor

  def start_link(init) do
    Supervisor.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      Alertas.Registry,
      Alertas.DynamicSupervisor,
      Alertas.Suscripcion.Supervisor
    ]
    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end
end

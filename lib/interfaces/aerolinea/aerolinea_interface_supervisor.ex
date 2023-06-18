defmodule Aerolinea.Interface.Supervisor do
  use Supervisor

  def start_link(init) do
    Supervisor.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {Registry, [keys: :unique, name: Aerolinea.Interface.Worker.Registry]},
      {Aerolinea.Interface.Worker, :aerolinea_interface_worker}
    ]

    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end
end

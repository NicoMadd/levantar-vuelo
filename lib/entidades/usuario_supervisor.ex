defmodule Entidades.Usuario.Supervisor do
  use Supervisor

  def start_link(init) do
    Supervisor.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [Entidades.Usuario.DynamicSupervisor, Entidades.Usuario.Registry]
    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end
end

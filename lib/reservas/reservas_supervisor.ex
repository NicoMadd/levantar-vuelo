defmodule Reservas.Supervisor do
  use Supervisor

  def start_link(init) do
    Supervisor.start_link(__MODULE__, init)
  end

  def init(_init_arg) do
    children = [Reservas.Worker]
    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end
end

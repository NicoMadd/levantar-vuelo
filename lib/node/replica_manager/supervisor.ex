defmodule Replica.Manager.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {Replica.Manager, [Replica.Manager]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

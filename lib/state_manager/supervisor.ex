defmodule State.Manager.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      %{
        id: State.Manager,
        start: {State.Manager, :start_link, [{}]}
      },
      %{
        id: State.Manager.Task.Supervisor,
        start: {State.Manager.Task.Supervisor, :start_link, [[]]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

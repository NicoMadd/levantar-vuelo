defmodule State.Manager.Task.Supervisor do
  def start_link(_args) do
    Task.Supervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one,
      max_restarts: 3,
      max_seconds: 5
    )
  end

  def get_previous_state(alerta_id, wait \\ 0) do
    Process.sleep(wait)

    Task.Supervisor.async(
      __MODULE__,
      State.Manager.Task,
      :get_previous_state,
      [alerta_id],
      restart: :transient
    )
  end
end

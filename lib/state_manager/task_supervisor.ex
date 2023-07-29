defmodule State.Manager.Task.Supervisor do
  def start_link(_args) do
    Task.Supervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one,
      max_restarts: 3,
      max_seconds: 5
    )
  end

  def get_state(alerta_id, retries \\ 0, default \\ nil, after_func \\ fn -> nil end) do
    Task.Supervisor.start_child(
      __MODULE__,
      State.Manager.Task,
      :get_state,
      [alerta_id, retries, 500, default, after_func],
      restart: :transient
    )
  end
end

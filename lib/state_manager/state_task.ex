defmodule State.Manager.Task do
  use Task

  def get_previous_state(alerta_id) do
    case State.Manager.get_state(alerta_id) do
      nil ->
        # Backoff de 1 segundo para esperar a la consistencia eventual de los CRDTs
        State.Manager.Task.Supervisor.get_previous_state(alerta_id, 1000)

      any ->
        any
    end
  end
end

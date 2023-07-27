defmodule Alertas.Suscripcion.Supervisor do

  def start_link(_args) do
    Task.Supervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one,
      max_restarts: 3,
      max_seconds: 5
    )
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def suscribir(usuario_id, type) do
    Task.Supervisor.start_child(__MODULE__, Alertas.Suscripcion, :suscribir, [usuario_id, type], restart: :permanent)
  end

end

defmodule Notification.Supervisor do
  def start_link(_init) do
    Task.Supervisor.start_link(name: __MODULE__)
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

  # Cliente

  def notificar(:vuelo, vuelo) do
    Task.Supervisor.start_child(__MODULE__, fn ->
      Notification.notificar_vuelo(vuelo)
    end)
  end

  def notificar(:cierre, vuelo) do
    Task.Supervisor.start_child(__MODULE__, fn ->
      Notification.notificar_cierre(vuelo)
    end)
  end
end

defmodule Vuelo.Notification do
  use Task
  require Logger

  def notificar(:vuelo, vuelo) do
    Task.start_link(__MODULE__, :notificar_vuelo, [vuelo])
  end

  def notificar_vuelo({vuelo_id, _info}) do
    Logger.info("Notificar #{vuelo_id}")
  end
end

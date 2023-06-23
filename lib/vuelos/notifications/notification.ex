defmodule Notification do
  use Task
  require Logger

  def notificar_vuelo({vuelo_id, info}) do
    Logger.info("Notificar nuevo vuelo #{vuelo_id}")

    {_, _, datetime, origen, destino, _} = info

    date = DateTime.to_date(datetime)

    month = date.month

    [datetime, month, origen, destino]
    |> Enum.map(fn dato -> {dato, Alertas.Registry.find_or_create_alerta(dato)} end)
    |> Enum.each(fn {dato, {_, pid}} -> Alerta.notificar_usuarios(pid, {vuelo_id, dato}) end)
  end

  def notificar_cierre({vuelo_id, info}) do
    Logger.info("Notificar #{vuelo_id}")

    {_, _, datetime, origen, destino, _} = info

    date = DateTime.to_date(datetime)

    month = date.month

    [datetime, month, origen, destino]
    |> Enum.map(fn dato -> {dato, Alertas.Registry.find_or_create_alerta(dato)} end)
    |> Enum.each(fn {dato, {_, pid}} -> Alerta.notificar_usuarios(pid, {vuelo_id, dato}) end)
  end
end

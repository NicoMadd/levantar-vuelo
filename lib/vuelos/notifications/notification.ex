defmodule Notification do
  use Task
  require Logger

  def notificar_vuelo({vuelo_id, info}) do
    Logger.info("Notificar nuevo vuelo #{vuelo_id}")

    {_, datetime, origen, destino, _} = info

    date = DateTime.to_date(datetime)

    month = date.month

    [{datetime, :fecha}, {month, :mes}, {origen, :origen}, {destino, :destino}]
    |> Enum.map(fn {alerta_id, type} ->
      {alerta_id, Alertas.Registry.find_or_create_alerta(alerta_id, type)}
    end)
    |> Enum.each(fn {alerta_id, {_, pid_alerta}} ->
      Alerta.notificar_usuarios(pid_alerta, {vuelo_id, alerta_id})
    end)
  end

  def notificar_cierre({vuelo_id}) do
    Logger.info("Notificar cierre #{vuelo_id}")

    vuelo_id
    |> Reservas.Registry.find_reservas_by_vuelo()
    |> Enum.each(fn {pid_reserva, _} -> Reserva.notificar_cierre(pid_reserva) end)
  end
end

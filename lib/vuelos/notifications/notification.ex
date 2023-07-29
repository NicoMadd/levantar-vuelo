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
      {alerta_id, Alertas.Registry.crear_alerta(alerta_id, type)}
    end)
    |> Enum.each(fn {alerta_id, {_, pid_alerta}} ->
      Alerta.notificar_usuarios(pid_alerta, {vuelo_id, alerta_id})
    end)
  end

  def notificar_cierre({vuelo_id}) do
    Logger.info("Notificar cierre #{vuelo_id}")

    [{pid_reserva, _}] = Reservas.Registry.find_reserva_by_vuelo(vuelo_id)

    send(pid_reserva, :cerrar_reservas)
  end
end

defmodule Alertas.Notifier do
  use GenServer
  require Logger

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :alertas_notifier)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  # Notificacion de un nuevo vuelo
  def notificacion_vuelo(_pid, info_vuelo) do
    {vuelo_id, _vuelo} = info_vuelo
    Logger.info("Nuevo vuelo " <> vuelo_id <> " notificado")

    # Fetch de alertas - Buscar alertas que coincidan con los datos suministrados del vuelo
    alertas = Alertas.DB.get_all()

    # Informar a los usuarios

    notificar_por_mes(info_vuelo, alertas)

    notificar_por_origen(info_vuelo, alertas)

    notificar_por_destino(info_vuelo, alertas)
  end

  # Private functions

  defp notificar_por_mes(info_vuelo, alertas) do
    {vuelo_id, vuelo} = info_vuelo
    {_, _, fecha, _origen, _destino, _} = vuelo
    mes = fecha.month
    IO.inspect(alertas)

    usuarios_a_alertar = Map.get(alertas, mes)

    Logger.info(
      "Notificando a " <> "#{length(usuarios_a_alertar)}" <> " usuarios para el mes: " <> "#{mes}"
    )

    Enum.each(usuarios_a_alertar, fn id ->
      Usuario.Interface.Worker.notificar_nuevo_vuelo(id, vuelo_id)
    end)
  end

  defp notificar_por_origen(info_vuelo, alertas) do
    {vuelo_id, vuelo} = info_vuelo
    {_, _, _fecha, origen, _destino, _} = vuelo

    IO.inspect(alertas)

    usuarios_a_alertar = Map.get(alertas, origen)

    Logger.info(
      "Notificando a " <>
        "#{length(usuarios_a_alertar)}" <> " usuarios para el origen: " <> "#{origen}"
    )

    Enum.each(usuarios_a_alertar, fn id ->
      Usuario.Interface.Worker.notificar_nuevo_vuelo(id, vuelo_id)
    end)
  end

  defp notificar_por_destino(info_vuelo, alertas) do
    {vuelo_id, vuelo} = info_vuelo
    {_, _, _fecha, _origen, destino, _} = vuelo

    IO.inspect(alertas)

    usuarios_a_alertar = Map.get(alertas, destino)

    Logger.info(
      "Notificando a " <>
        "#{length(usuarios_a_alertar)}" <> " usuarios para el destino: " <> "#{destino}"
    )

    Enum.each(usuarios_a_alertar, fn id ->
      Usuario.Interface.Worker.notificar_nuevo_vuelo(id, vuelo_id)
    end)
  end
end

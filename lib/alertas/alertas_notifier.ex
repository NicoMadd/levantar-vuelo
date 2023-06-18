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
    loggear_nuevo_vuelo(info_vuelo)

    # Fetch de alertas - Buscar alertas que coincidan con los datos suministrados del vuelo
    alertas = Alertas.DB.get_all()

    # Informar a los usuarios

    notificar_por_mes(info_vuelo, alertas)

    notificar_por_origen(info_vuelo, alertas)

    notificar_por_destino(info_vuelo, alertas)
  end

  # Private functions

  defp loggear_nuevo_vuelo({vuelo_id, _vuelo}) do
    Logger.info("Nuevo vuelo " <> vuelo_id <> " notificado")
  end

  defp notificar_por_mes({vuelo_id, vuelo}, alertas) do
    {_, _, fecha, _origen, _destino, _} = vuelo
    mes = fecha.month

    usuarios_a_alertar = Map.get(alertas, mes)

    mensaje =
      "Notificando a " <> "#{length(usuarios_a_alertar)}" <> " usuarios para el mes: " <> "#{mes}"

    notificar_usuarios(
      usuarios_a_alertar,
      vuelo_id,
      mensaje
    )
  end

  defp notificar_por_origen({vuelo_id, vuelo}, alertas) do
    {_, _, _fecha, origen, _destino, _} = vuelo

    usuarios_a_alertar = Map.get(alertas, origen)

    mensaje =
      "Notificando a " <>
        "#{length(usuarios_a_alertar)}" <> " usuarios para el origen: " <> "#{origen}"

    notificar_usuarios(
      usuarios_a_alertar,
      vuelo_id,
      mensaje
    )
  end

  defp notificar_por_destino({vuelo_id, vuelo}, alertas) do
    {_, _, _fecha, _origen, destino, _} = vuelo

    usuarios_a_alertar = Map.get(alertas, destino)

    mensaje =
      "Notificando a " <>
        "#{length(usuarios_a_alertar)}" <> " usuarios para el destino: " <> "#{destino}"

    notificar_usuarios(
      usuarios_a_alertar,
      vuelo_id,
      mensaje
    )
  end

  defp notificar_usuarios(usuarios, vuelo_id, mensaje) do
    Logger.info(mensaje)

    Enum.each(usuarios, fn id ->
      Usuario.Interface.Worker.notificar_nuevo_vuelo(id, vuelo_id)
    end)
  end
end

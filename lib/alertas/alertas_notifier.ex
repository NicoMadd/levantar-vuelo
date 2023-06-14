defmodule Alertas.Notifier do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :alertas_notifier)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  # Notificacion de un nuevo vuelo
  def notificacion_vuelo(_pid, info_vuelo) do
    {_vuelo_id, vuelo} = info_vuelo

    # Busca informacion para posibles alertas
    {_, _, fecha, _origen, _destino, _} = vuelo
    %{month: mes} = fecha

    # Buscar alertas que coincidan con los datos suministrados del vuelo

    # Informar a los usuarios
  end
end

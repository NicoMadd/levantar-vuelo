defmodule Alertas.Notifier do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :alertas_notifier)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  def notificacion_vuelo(_pid, info_vuelo) do
    {_vuelo_id, vuelo} = info_vuelo

    # Busca el mes
    {_, _, fecha, _origen, _destino, _} = vuelo
    %{month: mes} = fecha
    IO.puts(mes)
  end
end

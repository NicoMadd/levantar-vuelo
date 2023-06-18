defmodule Vuelos.DB do
  use Agent
  require Logger

  def start_link(_initial_value) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def cerrar_vuelo(id) do
    # Remuevo el vuelo
    Agent.update(__MODULE__, fn vuelos -> Map.delete(vuelos, id) end)

    # Notifico del cierre
    Reservas.Worker.notificacion_cierre_de_vuelo(:alertas_worker, {id})
  end

  # Client

  def agregar_vuelo(tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite) do
    # Crea el vuelo
    vuelo = {tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite}
    loggear_vuelo(vuelo)

    # Genera un id para el vuelo creado
    id = App.Utils.generate_id()

    Logger.info("Creando vuelo con id: " <> id)

    # Agrega el vuelo
    Agent.update(__MODULE__, fn vuelos -> Map.put(vuelos, id, vuelo) end)

    # Crea cancelacion de vuelo en tiempo_limite
    Process.send_after(self(), {:cerrar_vuelo, id}, tiempo_limite * 1000)

    # Envia un cast para avisar al alertas worker de nuevo vuelo agregado
    Alertas.Notifier.notificacion_vuelo(:alertas_worker, {id, vuelo})
    {:reply, :ok}
  end

  def get_all do
    Agent.get(__MODULE__, fn s -> s end)
  end

  defp loggear_vuelo({tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite}) do
    Logger.info(
      "Creando vuelo de " <>
        "#{cantidad_asientos}" <>
        " asientos en un " <>
        tipo_avion <>
        " con destino a " <>
        destino <>
        " saliendo de " <>
        origen <>
        ". Partira el " <>
        "#{DateTime.to_date(datetime)}" <>
        " a las " <>
        "#{DateTime.to_time(datetime)}" <>
        ". Podra ofertar por un tiempo de " <>
        "#{tiempo_limite}" <>
        " segundos."
    )
  end
end

defmodule Vuelos.DB do
  use Agent

  def start_link(_initial_value) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Client

  def agregar_vuelo(tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite) do
    # Crea el vuelo
    vuelo = vuelo(tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite)

    # Genera un id para el vuelo creado
    id = App.Utils.generate_id()

    # Agrega el vuelo
    Agent.update(__MODULE__, fn vuelos -> Map.put(vuelos, id, vuelo) end)

    # Envia un cast para avisar al alertas worker de nuevo vuelo agregado
    Alertas.Notifier.notificacion_vuelo(:alertas_worker, {id, vuelo})
    {:reply, :ok}
  end

  def get_all do
    Agent.get(__MODULE__, fn s -> s end)
  end

  defp vuelo(tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite) do
    {tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite}
  end
end

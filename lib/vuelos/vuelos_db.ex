defmodule Vuelos.DB do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Client

  def agregar_vuelo(tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite) do
    vuelo = vuelo(tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite)
    id = App.Utils.generate_id()
    Agent.update(__MODULE__, fn vuelos -> Map.put(vuelos, id, vuelo) end)
  end

  def get_all do
    Agent.get(__MODULE__, fn s -> s end)
  end

  defp vuelo(tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite) do
    {tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite}
  end
end

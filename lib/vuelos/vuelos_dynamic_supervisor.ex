defmodule Vuelos.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(_init) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child({tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite}) do
    vuelo_id = App.Utils.generate_id()

    spec =
      {Vuelo,
       {vuelo_id, {tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite}}}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # Cliente

  @doc """
  tipo_avion: string
  cantidad_asientos: number
  datetime: ~UTC datetime
  origen: string
  destino: string
  tiempo_limite: number: en segundos
  """
  def publicar_vuelo(tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite) do
    start_child({tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite})
  end
end

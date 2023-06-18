defmodule Vuelos.Worker do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :vuelos_worker)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  # Handles

  def handle_call(
        {:publicar, {tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite}},
        _,
        state
      ) do
    ## Agrega el vuelo al agent
    ## Es sicronico ya que debo asegurar que se haya agregado el vuelo antes de responder.
    Vuelos.DB.agregar_vuelo(
      tipo_avion,
      cantidad_asientos,
      datetime,
      origen,
      destino,
      tiempo_limite
    )

    {:reply, :ok, state}
  end

  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  # Funciones definidas para el cliente

  @doc """
  tipo_avion: string
  cantidad_asientos: number
  datetime: ~UTC datetime
  origen: string
  destino: string
  tiempo_limite: number: en segundos
  """
  def publicar_vuelo(pid, tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite) do
    GenServer.call(
      pid,
      {:publicar, {tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite}}
    )
  end

  def validar(_pid, _vuelo_id) do
    {:reply, :ok}
  end
end

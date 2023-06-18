defmodule Vuelos.Worker do
  use GenServer
  require Logger

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :vuelos_worker)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  # Handles

  def handle_info({:cerrar_vuelo, id}, state) do
    Vuelos.DB.cerrar_vuelo(id)
    {:noreply, state}
  end

  def handle_call({:asignar_asientos, {vuelo_id, asientos}}, _, state) do
    # fetch del vuelo
    vuelo = Vuelos.DB.get(vuelo_id)

    # validacion interna
    case _validar_asientos(vuelo, asientos) do
      {:ok, message} ->
        Logger.info(message)
        response = _asignar_asientos(vuelo_id, asientos)
        {:reply, response, state}

      {:error, message} ->
        {:reply, {:error, message}, state}

      {:none, message} ->
        {:reply, {:none, message}, state}
    end
  end

  def handle_call(
        {:publicar, {tipo_avion, cantidad_asientos, datetime, origen, destino, tiempo_limite}},
        _,
        state
      ) do
    Logger.info("Publicando vuelo")

    Logger.info(
      "#{tipo_avion} #{cantidad_asientos} #{datetime} #{origen} #{destino} #{tiempo_limite}"
    )

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

  def validar_vuelo(_pid, _vuelo_id) do
    {:reply, :ok}
  end

  def asignar_asientos(pid, vuelo_id, asientos) do
    GenServer.call(
      pid,
      {:asignar_asientos, {vuelo_id, asientos}}
    )
  end

  # Private functions

  defp _validar_asientos(nil, _asientos) do
    {:none, "No existe el vuelo"}
  end

  defp _validar_asientos(vuelo, asientos_a_ocupar) do
    {{_, cantidad_asientos_disponibles, _, _, _, _}, cantidad_asientos_ocupados} = vuelo

    if(cantidad_asientos_ocupados + asientos_a_ocupar <= cantidad_asientos_disponibles) do
      {:ok, "Los asientos a asignar estan disponibles"}
    else
      {:error, "No estan disponibles los asientos"}
    end
  end

  defp _asignar_asientos(vuelo_id, asientos) do
    {:reply, response} = Vuelos.DB.asignar_asientos(vuelo_id, asientos)
    {:ok, response}
  end
end

defmodule Vuelos.Worker do
  use GenServer
  require Logger

  @registry Vuelos.Worker.Registry

  def start_link(worker_id) do
    GenServer.start_link(__MODULE__, :ok, name: {:via, Registry, {@registry, worker_id}})
  end

  def child_spec({worker_id}) do
    %{
      id: worker_id,
      start: {__MODULE__, :start_link, [worker_id]},
      type: :worker
    }
  end

  def init(:ok) do
    {:ok, []}
  end

  # Handles

  def handle_info({:cerrar_vuelo, id}, state) do
    Vuelos.DB.cerrar_vuelo(id)
    {:noreply, state}
  end

  def handle_call({:validar_vuelo, vuelo_id}, _, state) do
    vuelo = Vuelos.DB.get(vuelo_id)
    response = _validar_vuelo(vuelo)
    {:reply, response, state}
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

  def validar_vuelo(pid, vuelo_id) do
    GenServer.call(pid, {:validar_vuelo, vuelo_id})
  end

  def asignar_asientos(pid, vuelo_id, asientos) do
    GenServer.call(
      pid,
      {:asignar_asientos, {vuelo_id, asientos}}
    )
  end

  # Private functions

  defp _validar_vuelo(nil) do
    :none
  end

  defp _validar_vuelo(_vuelo) do
    :ok
  end

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

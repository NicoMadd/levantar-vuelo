defmodule Vuelo do
  use GenServer
  require Logger

  @registry Vuelos.Registry

  def start_link(vuelo_id, info) do
    GenServer.start_link(__MODULE__, {vuelo_id, info},
      name: {:via, Registry, {@registry, vuelo_id}}
    )
  end

  # child spec
  def child_spec({vuelo_id, info}) do
    %{
      id: "vuelo#{vuelo_id}",
      start: {__MODULE__, :start_link, [vuelo_id, info]},
      type: :worker,
      restart: :transient
    }
  end

  def init({vuelo_id, info}) do
    {_, _, _, _, _, tiempo_limite} = info

    # Autoterminacion
    Process.send_after(self(), {:cerrar_vuelo}, tiempo_limite * 1000)

    # Notificacion de nuevo vuelo
    Vuelo.Notification.notificar(:vuelo, {vuelo_id, info})

    {:ok, {vuelo_id, info}}
  end

  # Handles

  def handle_call(:info, _from, {v, info}) do
    {:reply, info, {v, info}}
  end

  def handle_info({:cerrar_vuelo}, {vuelo_id, info}) do
    Logger.info("Vuelo #{vuelo_id} cerrandose")
    {:stop, :normal, {vuelo_id, info}}
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

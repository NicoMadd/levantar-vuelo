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
    {tipo_avion, _, datetime, origen, destino, tiempo_limite} = info

    # Autoterminacion
    Process.send_after(self(), :cerrar_vuelo, tiempo_limite * 1000)

    # Notificacion de nuevo vuelo
    Notification.Supervisor.notificar(:vuelo, {vuelo_id, info})

    vuelo_state = %VueloState{
      asientos: Vuelos.Asientos.Builder.build(tipo_avion),
      origen: origen,
      destino: destino,
      fecha_hora_despegue: datetime,
      tipo_avion: tipo_avion,
      tiempo_oferta: tiempo_limite
    }

    {:ok, {vuelo_id, vuelo_state}}
  end

  # Handles

  def handle_info(:cerrar_vuelo, {vuelo_id, vuelo_state}) do
    Logger.info("Vuelo #{vuelo_id} cerrandose")

    Notification.Supervisor.notificar(:cierre, {vuelo_id})

    {:stop, :normal, {vuelo_id, vuelo_state}}
  end

  def handle_call(:info, _from, {v, info}) do
    {:reply, info, {v, info}}
  end

  def handle_call({:asignar_asiento, asientos_buscados}, _, {vuelo_id, vuelo_state}) do
    case validar_asientos_buscados(vuelo_state.asientos, asientos_buscados) do
      {:ok, _msg} -> {:reply, {:ok, "asientos asignados"}, {vuelo_id, asignar_asientos(vuelo_state, asientos_buscados)}}
      {:error, error_msg} -> {:reply, {:error, error_msg}, {vuelo_id, vuelo_state}}
    end
  end

  # Funciones definidas para el cliente

  def validar_vuelo(pid, vuelo_id) do
    GenServer.call(pid, {:validar_vuelo, vuelo_id})
  end

  @spec asignar_asientos(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: any
  def asignar_asientos(pid, vuelo_id, asientos) do
    GenServer.call(
      pid,
      {:asignar_asientos, {vuelo_id, asientos}}
    )
  end

  # Private functions

  # asigna los asientos independientemente que esten ocupados o no. validar que los asientos esten libres antes de llamar a esta funcion
  defp asignar_asientos(vuelo_state, asientos_buscados) do
    lista_asientos_actualizada = Enum.map(vuelo_state.asientos, fn asiento_vuelo ->
      case Enum.find(asientos_buscados, &(&1.numero == asiento_vuelo.numero)) do
        %{pasajero: pasajero} -> %{asiento_vuelo | disponible?: false, pasajero: pasajero}
        _ -> asiento_vuelo
      end
    end)

    %{vuelo_state | asientos: lista_asientos_actualizada}
  end

  # aplica validaciones sobre asientos
  defp validar_asientos_buscados(lista_asientos, asientos_buscados) do
    cond do
      asientos_buscados_duplicados?(asientos_buscados) -> {:error, "Se informaron asientos duplicados"}
      !asientos_buscados_existen?(lista_asientos, asientos_buscados) -> {:error, "Algunos asientos solicitados no existen"}
      !asientos_buscados_libres?(lista_asientos, asientos_buscados) -> {:error, "Algunos asientos solicitados no estan libres"}
      true -> {:ok, ""}
    end
  end

  # Valida que los asientos se encuentren libres
  defp asientos_buscados_libres?(lista_asientos, asientos_buscados) do
    lista_asientos
    |> Enum.filter(fn asiento_vuelo -> Enum.any?(asientos_buscados, &(&1.numero == asiento_vuelo.numero)) end)
    |> Enum.all?(fn asiento_vuelo -> asiento_vuelo.disponible? end)
  end

  # Valida si existen los asientos
  defp asientos_buscados_existen?(lista_asientos, asientos_buscados) do
    asientos_buscados
    |> Enum.all?(fn asiento_buscado -> Enum.any?(lista_asientos, &(&1.numero == asiento_buscado.numero)) end)
  end

  # Valida la lista contiene asientos duplicados
  defp asientos_buscados_duplicados?(asientos_buscados) do
    asientos_buscados
    |> Enum.frequencies_by(fn asiento_buscado -> asiento_buscado.numero end)
    |> Map.to_list()
    |> Enum.any?(fn {_numero, cantidad} -> cantidad > 1 end)
  end

end

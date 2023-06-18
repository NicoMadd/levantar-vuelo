defmodule Reservas.Worker do
  use GenServer
  require Logger

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :reservas_worker)
  end

  def init(_init_arg) do
    {:ok, %{}}
  end

  # Handles

  # def handle_cast({:cierre_de_vuelo, {id}}, _state) do
  #   Logger.info("Cierre del vuelo: " <> id)
  # end

  def handle_call({:reservar_asientos, {reserva_id, asientos}}, _, state) do
    reserva = Reservas.DB.get(reserva_id)

    _reservar_asientos(reserva, asientos, state)
  end

  def handle_call({:iniciar_reserva, {vuelo_id, usuario_id}}, _from, state) do
    # validar inicio de reserva contra el vuelo
    if vuelo_disponible?(vuelo_id) do
    end

    Logger.info("Iniciando reserva con id: 123 para el usuario: #{usuario_id} vuelo: #{vuelo_id}")

    reserva_id = Reservas.DB.crear_reserva(vuelo_id, usuario_id)

    {:reply, {:ok, reserva_id}, state}
  end

  # Funciones definidas para el cliente

  def iniciar_reserva(pid, vuelo_id, usuario_id) do
    GenServer.call(pid, {:iniciar_reserva, {vuelo_id, usuario_id}})
  end

  def reservar_asientos(pid, reserva_id, asientos) do
    GenServer.call(pid, {:reservar_asientos, {reserva_id, asientos}})
  end

  def seleccionar_asientos(pid, reserva_id, asientos) do
    # validar seleccion de asientos
    # si falla o devuelve error o asincronicamente informa que se debe seleccionar asientos de nuevo
    # si es valida entonces confirma la compra del pasaje
  end

  # La reserva se puede cancelar ya sea por el propio usuario o por el cierre del vuelo
  def cancelar_reserva(pid, reserva_id, usuario_id) do
    # Cancelar reserva en la base
    Reservas.DB.cancelar(reserva_id)

    # Notificar al usuario de la cancelacion
  end

  def notificacion_cierre_de_vuelo(pid, id) do
    GenServer.cast(pid, {:cierre_de_vuelo, {id}})
  end

  ## ----- Private functions --------------------------------

  defp _reservar_asientos(nil, _, state) do
    {:reply, {:ok, "No existe la reserva"}, state}
  end

  defp _reservar_asientos(reserva, asientos, state) do
    {vuelo_id, usuario_id} = reserva

    # validar inicio de reserva contra el vuelo
    if vuelo_disponible?(vuelo_id) do
    end

    # asignar asientos
    asignar_asientos(vuelo_id, asientos)

    {:reply, :ok, state}
  end

  defp vuelo_disponible?(vuelo_id) do
    case Vuelos.Worker.validar_vuelo(:vuelos_worker, vuelo_id) do
      {:reply, :ok} ->
        true

      _ ->
        false
    end
  end

  defp asignar_asientos(vuelo_id, asientos) do
    Vuelos.Worker.asignar_asientos(:vuelos_worker, vuelo_id, asientos)
  end
end

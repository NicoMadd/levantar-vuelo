defmodule Reservas.Worker do
  use GenServer
  require Logger

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :reservas_worker)
  end

  def init(_init_arg) do
    {:ok, {%{}, 1}}
  end

  # Handles

  def handle_cast({:cierre_de_vuelo, {id}}, _state) do
    Logger.info("Cierre del vuelo: " <> id)
  end

  def handle_call({:reservar, {vuelo_id, usuario_id}}, _, {vuelos, id_seq}) do
    {:reply, :ok, {vuelos, id_seq}}
  end

  # Funciones definidas para el cliente

  def reservar(pid, vuelo_id, usuario_id) do
    # validar inicio de reserva contra el vuelo
    if vueloDisponible?(vuelo_id) do
      GenServer.call(pid, {:reservar, {vuelo_id, usuario_id}})
    end
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

  defp vueloDisponible?(vuelo_id) do
    case Vuelos.Worker.validar(:vuelos_worker, vuelo_id) do
      {:reply, :ok} ->
        true

      _ ->
        false
    end
  end
end

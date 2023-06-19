defmodule Usuario.Interface.Worker do
  use GenServer
  require Logger

  @registry Usuario.Interface.Worker.Registry

  def start_link(usuario_id) do
    GenServer.start_link(__MODULE__, {:ok, usuario_id},
      name: {:via, Registry, {@registry, usuario_id}}
    )
  end

  def init({:ok, usuario_id}) do
    {:ok, {usuario_id, []}}
  end

  # Handles

  def handle_cast({:notificar_nuevo_vuelo, {vuelo_id}}, _from, {usuario_id, vuelos}) do
    Logger.info(
      "Notificando nuevo vuelo a usuario: " <> "#{usuario_id}" <> " por el vuelo: " <> vuelo_id
    )

    {:noreply, {usuario_id, vuelos}}
  end

  def handle_cast({:notificar_cierre_vuelo, {vuelo_id}}, _from, {usuario_id, vuelos}) do
    Logger.info(
      "Notificando cierre de vuelo a usuario: " <>
        "#{usuario_id}" <> " por el vuelo: " <> vuelo_id
    )

    {:noreply, {usuario_id, vuelos}}
  end

  def handle_call({:iniciar_reserva, {vuelo_id}}, _from, {usuario_id, vuelos}) do
    Logger.info(
      "Iniciando reserva para el vuelo " <> vuelo_id <> " para el usuario: #{usuario_id}"
    )

    Reservas.Worker.iniciar_reserva(:reservas_worker, vuelo_id, {usuario_id, vuelos})
    {:reply, :ok, {usuario_id, vuelos}}
  end

  def handle_call({:reservar_asientos, {reserva_id, asientos}}, _from, {usuario_id, vuelos}) do
    Logger.info("Seleccionando #{asientos} asientos para la reserva #{reserva_id}")

    Reservas.Worker.reservar_asientos(:reservas_worker, reserva_id, asientos)
    {:reply, :ok, {usuario_id, vuelos}}
  end

  def notificar_nuevo_vuelo(usuario_id, vuelo_id) do
    case Registry.lookup(@registry, usuario_id) do
      [{pid, _}] ->
        GenServer.cast(pid, {:notificar_nuevo_vuelo, {vuelo_id}})

      _ ->
        {:none}
    end
  end

  def notificar_cierre_vuelo(usuario_id, vuelo_id) do
    case Registry.lookup(@registry, usuario_id) do
      [{pid, _}] ->
        GenServer.cast(pid, {:notificar_cierre_vuelo, {vuelo_id}})

      _ ->
        {:none}
    end
  end

  def iniciar_reserva(usuario_id, vuelo_id) do
    case Registry.lookup(@registry, usuario_id) do
      [{pid, _}] ->
        GenServer.call(pid, {:iniciar_reserva, {vuelo_id}})

      _ ->
        {:none}
    end
  end

  def reservar_asientos(usuario_id, reserva_id, asientos) do
    case Registry.lookup(@registry, usuario_id) do
      [{pid, _}] ->
        GenServer.call(pid, {:reservar_asientos, {reserva_id, asientos}})

      _ ->
        {:none}
    end
  end
end

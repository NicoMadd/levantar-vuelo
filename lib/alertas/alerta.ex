defmodule Alerta do
  require Logger
  use GenServer

  @registry Alertas.Registry
  def start_link({alerta_id, type}) do
    GenServer.start_link(__MODULE__, {alerta_id, type, []}, name: via_tuple(alerta_id))
  end

  def via_tuple(alerta_id) do
    {:via, Horde.Registry, {@registry, alerta_id}}
  end

  def init({mes, :mes, suscribers}) do
    Process.flag(:trap_exit, true)
    {:ok, {{mes, :mes}, suscribers}, {:continue, :load_state}}
  end

  def init({fecha, :fecha, suscribers}) do
    Process.flag(:trap_exit, true)
    {:ok, {{fecha, :fecha}, suscribers}, {:continue, :load_state}}
  end

  def init({origen, :origen, suscribers}) do
    Process.flag(:trap_exit, true)
    {:ok, {{origen, :origen}, suscribers}, {:continue, :load_state}}
  end

  def init({destino, :destino, suscribers}) do
    Process.flag(:trap_exit, true)
    {:ok, {{destino, :destino}, suscribers}, {:continue, :load_state}}
  end

  # terminate handle
  def terminate(_reason, state) do
    # save state to state manager
    {alerta_id, suscribers} = state
    State.Manager.save_state(alerta_id, suscribers)
  end

  # handle load state
  def handle_continue(:load_state, arg) do
    {:noreply, load_state(arg)}
  end

  def load_state({id_alerta, _suscribers}) do
    pid = self()

    State.Manager.get_state(id_alerta, 3, [], fn result ->
      # Se auto envia el resultado
      Alerta.refresh_state(pid, result)
    end)

    {id_alerta, []}
  end

  # Handles

  def handle_call({:suscribir, usuario_id}, _from, {{alerta_id, type}, lista}) do
    loggear_suscripcion(usuario_id, alerta_id, type)

    {:reply, :ok, {{alerta_id, type}, Enum.uniq([usuario_id | lista])}}
  end

  def handle_cast({:refresh_state, new_suscribers}, {alerta, lista}) do
    {:noreply, {alerta, Enum.uniq(Enum.concat(lista, new_suscribers))}}
  end

  def handle_cast({:notificar_usuarios, {vuelo_id, dato}}, {{mes, :mes}, lista}) do
    if dato == mes do
      lista
      |> Enum.each(fn e ->
        IO.puts("Notificando usuario #{e} de un nuevo vuelo #{vuelo_id} en el mes #{mes}")
      end)
    end

    {:noreply, {{mes, :mes}, lista}}
  end

  def handle_cast({:notificar_usuarios, {vuelo_id, dato}}, {{fecha, :fecha}, lista}) do
    if dato == fecha do
      lista
      |> Enum.each(fn e ->
        IO.puts("Notificando usuario #{e} de un nuevo vuelo #{vuelo_id} en la fecha #{fecha}")
      end)
    end

    {:noreply, {{fecha, :fecha}, lista}}
  end

  def handle_cast({:notificar_usuarios, {vuelo_id, dato}}, {{destino, :destino}, lista}) do
    if dato == destino do
      lista
      |> Enum.each(fn e ->
        IO.puts("Notificando usuario #{e} de un nuevo vuelo #{vuelo_id} en el destino #{destino}")
      end)
    end

    {:noreply, {{destino, :destino}, lista}}
  end

  def handle_cast({:notificar_usuarios, {vuelo_id, dato}}, {{origen, :origen}, lista}) do
    if dato == origen do
      lista
      |> Enum.each(fn e ->
        IO.puts("Notificando usuario #{e} de un nuevo vuelo #{vuelo_id} en el origen #{origen}")
      end)
    end

    {:noreply, {{origen, :origen}, lista}}
  end

  # Funciones definidas para el cliente

  @doc """
  Suscribe a un cliente a la lista de esa alerta
  """
  def suscribir(pid, usuario_id) do
    GenServer.call(pid, {:suscribir, usuario_id})
  end

  def notificar_usuarios(pid, vuelo) do
    GenServer.cast(pid, {:notificar_usuarios, vuelo})
  end

  def refresh_state(pid, new_suscribers) do
    GenServer.cast(pid, {:refresh_state, new_suscribers})
  end

  # Privadas

  defp loggear_suscripcion(usuario_id, alerta_id, :mes)
       when is_integer(alerta_id) and alerta_id >= 1 and alerta_id <= 12 do
    Logger.info(
      "Suscribiendo al usuario #{usuario_id} a la lista de alertas del mes #{alerta_id}"
    )
  end

  defp loggear_suscripcion(usuario_id, alerta_id, :origen) when is_bitstring(alerta_id) do
    Logger.info(
      "Suscribiendo al usuario #{usuario_id} a la lista de alertas del origen #{alerta_id}"
    )
  end

  defp loggear_suscripcion(usuario_id, alerta_id, :destino) do
    Logger.info(
      "Suscribiendo al usuario #{usuario_id} a la lista de alertas de la fecha #{alerta_id}"
    )
  end

  defp loggear_suscripcion(usuario_id, alerta_id, :fecha) do
    Logger.info(
      "Suscribiendo al usuario #{usuario_id} a la lista de alertas por fecha #{alerta_id}"
    )
  end
end

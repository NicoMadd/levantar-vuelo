defmodule Alerta do
  require Logger
  use GenServer

  @registry Alertas.Registry
  def start_link({alerta_id, type}) do
    GenServer.start_link(__MODULE__, {alerta_id, type},
      name: via_tuple(alerta_id, type)
    )
  end

  def via_tuple(alerta_id, type) do
    {:via, Horde.Registry, {@registry, {alerta_id, type}}}
  end

  def init({mes, :mes}) do
    {:ok, {{mes, :mes}, []}}
  end

  def init({fecha, :fecha}) do
    {:ok, {{fecha, :fecha}, []}}
  end

  def init({origen, :origen}) do
    {:ok, {{origen, :origen}, []}}
  end

  def init({destino, :destino}) do
    {:ok, {{destino, :destino}, []}}
  end

  # Handles

  def handle_call({:suscribir, usuario_id}, _from, {{alerta_id, type}, lista}) do
    loggear_suscripcion(usuario_id, alerta_id, type)

    {:reply, :ok, {{alerta_id, type}, Enum.uniq([usuario_id | lista])}}
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

  # Privadas

  defp loggear_suscripcion(usuario_id, alerta_id, :mes) do
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

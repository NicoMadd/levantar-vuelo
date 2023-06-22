defmodule Alerta do
  require Logger
  use GenServer

  @registry Alertas.Registry
  def start_link(alerta_id) do
    GenServer.start_link(__MODULE__, alerta_id, name: {:via, Registry, {@registry, alerta_id}})
  end

  def init(alerta_id) do
    {:ok, {alerta_id, []}}
  end

  # Handles

  def handle_call({:suscribir, usuario_id}, _from, {alerta_id, lista}) do
    loggear_suscripcion(usuario_id, alerta_id)

    {:reply, :ok, {alerta_id, Enum.uniq([usuario_id | lista])}}
  end

  # Funciones definidas para el cliente

  @doc """
  Suscribe a un cliente a la lista de esa alerta
  """
  def suscribir(pid, usuario_id) do
    GenServer.call(pid, {:suscribir, usuario_id})
  end

  # Privadas

  defp loggear_suscripcion(usuario_id, alerta_id)
       when is_integer(alerta_id) and alerta_id >= 1 and alerta_id <= 12 do
    Logger.info("Suscribiendo al usuario #{usuario_id} a la lista del mes #{alerta_id}")
  end

  defp loggear_suscripcion(usuario_id, alerta_id) when is_bitstring(alerta_id) do
    Logger.info("Suscribiendo al usuario #{usuario_id} a la lista del origen #{alerta_id}")
  end

  defp loggear_suscripcion(usuario_id, alerta_id) do
    Logger.info("Suscribiendo al usuario #{usuario_id} a la lista de la fecha #{alerta_id}")
  end
end

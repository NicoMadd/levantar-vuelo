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

  def handle_cast({:notificar_usuarios, {vuelo_id, _dato}}, {alerta, lista_usuarios}) do

    for usuario <- lista_usuarios do
      [{pid, _}] = Entidades.Usuario.Registry.find(usuario)
      GenServer.cast(pid, {:nuevo_vuelo, vuelo_id, alerta})
    end

    {:noreply, {alerta, lista_usuarios}}
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

defmodule Reserva do
  use GenServer
  require Logger

  @registry Reservas.Registry

  def start_link(vuelo_id) do
    GenServer.start_link(__MODULE__, {vuelo_id},
    name: via_tuple(vuelo_id))
  end

  defp via_tuple(vuelo_id) do
    {:via, Horde.Registry, {@registry, vuelo_id}}
  end

  # child spec
  def child_spec({vuelo_id}) do
    %{
      id: "reserva#{vuelo_id}",
      start: {__MODULE__, :start_link, [vuelo_id]},
      type: :worker,
      restart: :transient
    }
  end

  def init({vuelo_id}) do
    # Registry.register(Reservas.Registry, vuelo_id, {usuario_id})

    {:ok, {vuelo_id, []}}
  end

  # Handles

  def handle_call({:reservar, usuario_id}, _from, {vuelo_id, lista_usuarios}) do
    {:reply, :ok, {vuelo_id, Enum.uniq([usuario_id | lista_usuarios])}}
  end

  def handle_call({:cancelar_reserva, usuario_id}, _from, {vuelo_id, lista_usuarios}) do
    usuarios = Enum.filter(lista_usuarios, fn id -> id != usuario_id end)
    {:reply, :ok, {vuelo_id, usuarios}}
  end


  def handle_call({:asignar_asientos, {usuario_id, asientos_buscados}}, _from, {vuelo_id, lista_usuarios}) do
    [{pid, _}] = Vuelos.Registry.find(vuelo_id)

    lista_sin_usuario_reserva = Enum.filter(lista_usuarios, fn id -> id != usuario_id end)

    case GenServer.call(pid, {:asignar_asiento, asientos_buscados}) do
      {:ok, _} ->
        {:reply, {:ok, ""}, {vuelo_id, lista_sin_usuario_reserva}}
      {:error, error_msg} ->
        {:reply, {:error, error_msg}, {vuelo_id, lista_usuarios}}
    end
  end

  def handle_info(:cerrar_reservas, {vuelo_id, lista_usuarios}) do
    Logger.info("Notificando usuarios: #{inspect(lista_usuarios)} del cierre del vuelo #{vuelo_id}.")
    # restaría notificar a los usuarios mediante

    for usuario <- lista_usuarios do
        [{pid, _}] = Entidades.Usuario.Registry.find(usuario)
        GenServer.cast(pid, {:cierre_reserva, vuelo_id})
    end

    {:stop, :normal, {vuelo_id, lista_usuarios}}
  end

  # Cliente
  # def cerrar(pid) do
  #   pid_string = pid |> :erlang.pid_to_list |> to_string
  #   Logger.info("Notificar cierre. Pid reserva: #PID#{pid_string}.")
  #   GenServer.cast(pid, :cierre_reserva)
  # end
end

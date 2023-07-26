defmodule Reserva do
  use GenServer
  require Logger

  @registry Reservas.Registry

  def start_link(vuelo_id, usuario_id) do
    GenServer.start_link(__MODULE__, {vuelo_id, usuario_id})
  end

  defp via_tuple(vuelo_id, usuario_id) do
    {:via, Registry, {@registry, vuelo_id, {usuario_id}}}
  end

  # child spec
  def child_spec({vuelo_id, usuario_id}) do
    %{
      id: "reserva#{vuelo_id}#{usuario_id}",
      start: {__MODULE__, :start_link, [vuelo_id, usuario_id]},
      type: :worker,
      restart: :transient
    }
  end

  def init({vuelo_id, usuario_id}) do
    Registry.register(Reservas.Registry, vuelo_id, {usuario_id})

    {:ok, {vuelo_id, usuario_id}}
  end

  # Handles

  def handle_cast(:cierre, {vuelo_id, usuario_id}) do
    Logger.info("Notificando usuario #{usuario_id} del cierre del vuelo #{vuelo_id}.")
    # restaría notificar al usuario mediante el usuario_id
    {:stop, :normal, {vuelo_id, usuario_id}}
  end

  def handle_call({:asignar_asientos, asientos_buscados}, {vuelo_id, usuario_id}) do
    {pid, _} = Vuelos.Registry.find(vuelo_id)

    case GenServer.call(pid, {:asignar_asiento, asientos_buscados}) do
      {:ok, _} ->
        {:reply, {:ok, ""}, {vuelo_id, usuario_id}}
      {:error, error_msg} ->
        {:reply, {:error, error_msg}, {vuelo_id, usuario_id}}
    end
  end

  # Cliente
  def cerrar(pid) do
    pid_string = pid |> :erlang.pid_to_list |> to_string
    Logger.info("Notificar cierre. Pid reserva: #PID#{pid_string}.")
    GenServer.cast(pid, :cierre)
  end
end

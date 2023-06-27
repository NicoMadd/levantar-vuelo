defmodule Reserva do
  use GenServer
  require Logger

  @registry Reservas.Registry

  def start_link(vuelo_id, usuario_id) do
    GenServer.start_link(__MODULE__, {vuelo_id, usuario_id},
      name: via_tuple(vuelo_id, usuario_id)
    )
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
    {:ok, {vuelo_id, usuario_id}}
  end

  # Handles

  def handle_cast(:cierre, {vuelo_id, usuario_id}) do
    IO.puts("Notificando usuario #{usuario_id} del cierre del vuelo #{vuelo_id}.")
    # restaría notificar al usuario mediante el usuario_id
    {:stop, :normal, {vuelo_id, usuario_id}}
  end

  # Cliente
  def notificar_cierre(pid) do
    pid_string = pid |> :erlang.pid_to_list |> to_string
    Logger.info("Notificar cierre. Pid reserva: #PID#{pid_string}.")
    GenServer.cast(pid, :cierre)
  end
end

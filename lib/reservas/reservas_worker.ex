defmodule Reservas.Worker do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :reservas_worker)
  end

  def init(_init_arg) do
    {:ok, {%{}, 1}}
  end

  # Handles

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

  defp vueloDisponible?(vuelo_id) do
    case Vuelos.Worker.validar(:vuelos_worker, vuelo_id) do
      {:reply, :ok} ->
        true

      _ ->
        false
    end
  end
end

defmodule Reservas.Registry do
  require Logger

  def start_link(_init) do
    Registry.start_link(keys: :duplicate, name: __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(_init_arg) do
    {:ok, []}
  end

  def find(vuelo_id, usuario_id) do
    Registry.match(__MODULE__, vuelo_id, {usuario_id}) |> List.first
  end

  def find_reservas_by_vuelo(vuelo_id) do
    Registry.lookup(__MODULE__, vuelo_id)
  end

  def cerrar_reservas(vuelo_id) do
    Registry.dispatch(Reservas.Registry, vuelo_id, fn entries ->
      for {pid, _} <- entries, do: Reserva.cerrar(pid)
    end)
  end

end

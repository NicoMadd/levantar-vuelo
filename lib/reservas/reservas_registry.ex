defmodule Reservas.Registry do
  require Logger

  def start_link(_init) do
    Registry.start_link(keys: :unique, name: __MODULE__)
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

  def find(usuario_id, vuelo_id) do
    Registry.lookup(__MODULE__, {usuario_id, vuelo_id})
  end

  def find_reservas_by_vuelo(vuelo_id) do
    # FIXME - Corregir que devuelva las reservas de forma correcta. Al momento devuelve un array vacion ya que no puede hacer pattern matching.
    Registry.lookup(__MODULE__, {nil, vuelo_id})
  end
end

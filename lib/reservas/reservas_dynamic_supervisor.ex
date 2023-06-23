defmodule Reservas.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(_init) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child({usuario_id, vuelo_id}) do
    spec = {Reserva, {usuario_id, vuelo_id}}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # Cliente

  @doc """
  tipo_avion: string
  cantidad_asientos: number
  datetime: ~UTC datetime
  origen: string
  destino: string
  tiempo_limite: number: en segundos
  """
  def iniciar_reserva(usuario_id, vuelo_id) do
    start_child({usuario_id, vuelo_id})
  end
end

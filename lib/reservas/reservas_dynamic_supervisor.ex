defmodule Reservas.DynamicSupervisor do
  use Horde.DynamicSupervisor
  require Logger

  def start_link(opts) do
    Horde.DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(init_arg) do
    [
      members: members(),
      strategy: :one_for_one,
      distribution_strategy: Horde.UniformQuorumDistribution,
      process_redistribution: :active
    ]
    |> Keyword.merge(init_arg)
    |> Horde.DynamicSupervisor.init()
  end

  defp members do
    Enum.map(Node.list([:this, :visible]), &{__MODULE__, &1})
  end

  def start_child(vuelo_id) do
    spec = {Reserva, {vuelo_id}}

    # Logger.info("Creando reserva sobre el vuelo #{vuelo_id} para el usuario #{usuario_id}")

    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
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
  def iniciar_reserva(vuelo_id) do
    start_child(vuelo_id)
  end
end

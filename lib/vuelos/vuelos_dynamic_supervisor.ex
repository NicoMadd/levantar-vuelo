defmodule Vuelos.DynamicSupervisor do
  use Horde.DynamicSupervisor

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

  def start_child({tipo_avion, datetime, origen, destino, tiempo_limite}) do
    vuelo_id = App.Utils.generate_id()

    spec = {Vuelo, {vuelo_id, {tipo_avion, datetime, origen, destino, tiempo_limite}}}

    Horde.DynamicSupervisor.start_child(__MODULE__, spec)

    {:ok, vuelo_id}
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
  def publicar_vuelo(tipo_avion, datetime, origen, destino, tiempo_limite) do
    {:ok, vuelo_id} = start_child({tipo_avion, datetime, origen, destino, tiempo_limite})

    Reservas.DynamicSupervisor.iniciar_reserva(vuelo_id)

    {:ok, vuelo_id}
  end
end

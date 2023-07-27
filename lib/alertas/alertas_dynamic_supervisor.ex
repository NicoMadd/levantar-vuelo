defmodule Alertas.DynamicSupervisor do
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

  def start_child(alerta_id, type) do
    spec = {Alerta, {alerta_id, type}}

    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # Cliente

  def crear_alerta_por_mes(usuario_id, mes) do
    {:ok, pid} = Alertas.Registry.find_or_create_alerta(mes, :mes)
    Alerta.suscribir(pid, usuario_id)
  end

  def crear_alerta_por_fecha(usuario_id, fecha) do
    {:ok, pid} = Alertas.Registry.find_or_create_alerta(fecha, :fecha)
    Alerta.suscribir(pid, usuario_id)
  end

  def crear_alerta_por_origen(usuario_id, origen) do
    {:ok, pid} = Alertas.Registry.find_or_create_alerta(origen, :origen)
    Alerta.suscribir(pid, usuario_id)
  end

  def crear_alerta_por_destino(usuario_id, destino) do
    {:ok, pid} = Alertas.Registry.find_or_create_alerta(destino, :destino)
    Alerta.suscribir(pid, usuario_id)
  end
end

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
    crear_alerta(usuario_id, {mes, :mes})
  end

  def crear_alerta_por_fecha(usuario_id, fecha) do
    crear_alerta(usuario_id, {fecha, :fecha})
  end

  def crear_alerta_por_origen(usuario_id, origen) do
    crear_alerta(usuario_id, {origen, :origen})
  end

  def crear_alerta_por_destino(usuario_id, destino) do
    crear_alerta(usuario_id, {destino, :destino})
  end

  # Private

  defp crear_alerta(usuario_id, type) do
    Task.Supervisor.start_child(Alertas.Suscripcion.Supervisor, Alertas.Suscripcion, :suscribir, [usuario_id, type])
  end

end

defmodule Entidades.Usuario.DynamicSupervisor do
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

  def start_child(id, nombre) do
    spec = {Entidades.Usuario, {id, nombre}}

    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def crear_usuario(nombre) do
    id = App.Utils.random_string(10)
    start_child(id, nombre)
    {:ok, id}
  end
end

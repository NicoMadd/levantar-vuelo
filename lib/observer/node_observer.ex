defmodule NodeObserver do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl GenServer
  def init(state) do
    # https://erlang.org/doc/man/net_kernel.html#monitor_nodes-1
    :net_kernel.monitor_nodes(true, node_type: :visible)

    {:ok, state}
  end

  @impl GenServer
  @doc """
  Handler that will be called when a node has left the cluster.
  """
  def handle_info({:nodedown, node, _node_type}, state) do
    Logger.info("---- Node down: #{node} ----")

    :telemetry.execute(
      [:node, :event, :down],
      %{node_affected: node},
      %{}
    )

    # Supervisors
    set_members(Entidades.Usuario.DynamicSupervisor)
    set_members(Alertas.DynamicSupervisor)
    set_members(Reservas.DynamicSupervisor)
    set_members(Vuelos.DynamicSupervisor)

    # Registries
    set_members(Vuelos.Registry)
    set_members(Reservas.Registry)
    set_members(Entidades.Usuario.Registry)
    set_members(Alertas.Registry)

    # Delta CRDT
    State.Manager.refresh_neighbours()

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nodeup, node, _node_type}, state) do
    Logger.info("---- Node up: #{node} ----")

    :telemetry.execute(
      [:node, :event, :up],
      %{node_affected: node},
      %{}
    )

    # Supervisors
    set_members(Entidades.Usuario.DynamicSupervisor)
    set_members(Alertas.DynamicSupervisor)
    set_members(Reservas.DynamicSupervisor)
    set_members(Vuelos.DynamicSupervisor)

    # Registries
    set_members(Vuelos.Registry)
    set_members(Reservas.Registry)
    set_members(Entidades.Usuario.Registry)
    set_members(Alertas.Registry)

    # Delta CRDT
    State.Manager.refresh_neighbours()

    {:noreply, state}
  end

  defp set_members(name) do
    members = Enum.map([Node.self() | Node.list()], &{name, &1})

    :ok = Horde.Cluster.set_members(name, members)
  end
end

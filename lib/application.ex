defmodule LevantarVuelo.Application do
  use Application

  def start(_start_type, _start_args) do
    IO.puts("Arranca")

    children = [
      ## Horde Cluster ##
      {Cluster.Supervisor, [topologies(), [name: LevantarVuelo.ClusterSupervisor]]},

      ## Basics ##
      Vuelos.Supervisor,
      Alertas.Supervisor,
      Reservas.Supervisor,
      Entidades.Usuario.Supervisor,

      ## API ##
      API.Supervisor,

      ## Node Observer ##
      NodeObserver.Supervisor,
    ]

    opts = [strategy: :one_for_one]

    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      horde_minimal_example: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]
  end
end

defmodule LevantarVuelo.Application do
  use Application

  def start(_start_type, _start_args) do
    IO.puts("Arranca")

    topologies = [
      myapp: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      # libcluster
      {Cluster.Supervisor, [topologies, [name: MyApp.ClusterSupervisor]]},
      Node.Observer.Supervisor,
      Replica.Manager.Supervisor,
      Vuelos.Supervisor,
      Alertas.Supervisor,
      Reservas.Supervisor
      # API.Supervisor
    ]

    opts = [strategy: :one_for_one]

    Supervisor.start_link(children, opts)
  end
end

defmodule LevantarVuelo.Application do
  use Application

  def start(_start_type, _start_args) do
    IO.puts("Arranca")

    children = [
      Vuelos.Supervisor,
      Alertas.Supervisor,
      Reservas.Supervisor
      # Aerolinea.Interface.Supervisor,
      # Usuario.Interface.Supervisor
    ]

    opts = [strategy: :one_for_one]

    Supervisor.start_link(children, opts)
  end
end

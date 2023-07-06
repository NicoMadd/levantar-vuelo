defmodule Aerolinea.Supervisor do
  use Supervisor

  def start_link(init) do
    Supervisor.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Aerolinea.Router, options: [port: cowboy_port()]}
    ]

    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end

  defp cowboy_port, do: 8080
end

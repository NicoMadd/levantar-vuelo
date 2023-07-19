defmodule Aerolinea.Supervisor do
  use Supervisor

  def start_link(init) do
    Supervisor.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Aerolinea.Router, options: [port: cowboy_rest_port()]},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Aerolinea.Websocket.Router,
        options: [dispatch: dispatch(), port: cowboy_ws_port()]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Aerolinea.Websocket.Registry
      )
    ]

    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end

  defp cowboy_rest_port, do: 5000
  defp cowboy_ws_port, do: 4000

  defp dispatch do
    [
      {:_,
       [
         {"/ws/aerolinea", Aerolinea.Websocket.Handler, []}
       ]}
    ]
  end
end
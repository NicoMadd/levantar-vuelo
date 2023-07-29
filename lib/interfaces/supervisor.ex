defmodule API.Supervisor do
  use Supervisor

  def start_link(init) do
    Supervisor.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Aerolinea.Router, options: [port: cowboy_rest_port()]},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Websocket.Router,
        options: [dispatch: dispatch(), port: cowboy_ws_port()]
      ),
      Aerolinea.Websocket.Registry,
      Usuario.Websocket.Registry
    ]

    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end

  defp cowboy_rest_port, do: 5000 #get_free_port(5000)
  defp cowboy_ws_port, do: 4000 #get_free_port(4000)

  defp dispatch do
    [
      {:_,
       [
         {"/ws/aerolinea", Aerolinea.Websocket.Handler, []},
         {"/ws/usuario", Usuario.Websocket.Handler, []}
       ]}
    ]
  end

  defp get_free_port(start) do
    case :gen_tcp.listen(start, [:binary]) do
      {:ok, socket} ->
        :ok = :gen_tcp.close(socket)
        start

      {:error, :eaddrinuse} ->
        get_free_port(start + 1)
    end
  end

end

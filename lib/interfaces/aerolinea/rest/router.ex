defmodule Aerolinea.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/aerolineas" do
    # TODO Get aerolineas disponibles y devolverlas
    send_resp(conn, 200, "OK")
  end

  post "/vuelos" do
    # TODO testear validacion de parametros
    IO.inspect(conn.body_params)

    tipo_avion = conn.body_params["tipo"]
    origen = conn.body_params["origen"]
    destino = conn.body_params["destino"]
    datetime = conn.body_params["fecha"]
    tiempo_limite = conn.body_params["limite"]

    Vuelos.DynamicSupervisor.publicar_vuelo(tipo_avion, datetime, origen, destino, tiempo_limite)
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end

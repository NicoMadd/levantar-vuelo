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

    tipo_avion = validar_tipo(conn.body_params["tipo"])
    origen = conn.body_params["origen"]
    destino = conn.body_params["destino"]
    datetime = validar_fecha(conn.body_params["fecha"])
    tiempo_limite = conn.body_params["limite"]

    Vuelos.DynamicSupervisor.publicar_vuelo(tipo_avion, datetime, origen, destino, tiempo_limite)
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp validar_tipo(tipo) do
    case tipo do
      "Embraer" -> :embraer190
      "Boeing" -> :boeing737
      _ -> :embraer190
    end
  end

  defp validar_fecha(fecha_string) do
    # fecha viene como string. Lo parseo a datetime.
    {:ok, datetime, _} = DateTime.from_iso8601(fecha_string)
    datetime
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end

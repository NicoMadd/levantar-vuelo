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

    {:ok, vuelo_id} = Vuelos.DynamicSupervisor.publicar_vuelo(tipo_avion, datetime, origen, destino, tiempo_limite)

    send_resp(conn, 201, "{\"id\": \"#{vuelo_id}\"}")
  end

  get "/vuelos/:vuelo_id" do
    # TODO testear validacion de parametros
    case Vuelos.Registry.find(vuelo_id) do
      [{pid, _}] -> send_resp(conn, 200, obtener_datos_vuelo(pid))
      [] -> send_resp(conn, 404, "")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp obtener_datos_vuelo(pid_vuelo) do
    vuelo_info_struct = GenServer.call(pid_vuelo, :info)

    asientos = Enum.map(vuelo_info_struct.asientos, fn a ->
      %{
        numero: a.numero,
        disponible?: a.disponible?,
        pasajero: a.pasajero
      }
    end)

    vuelo_map_info = %{
      tipo_avion: vuelo_info_struct.tipo_avion,
      fecha_hora_despegue: vuelo_info_struct.fecha_hora_despegue,
      origen: vuelo_info_struct.origen,
      destino: vuelo_info_struct.destino,
      tiempo_oferta: vuelo_info_struct.tiempo_oferta,
      asientos: asientos
    }
    
    Jason.encode(vuelo_map_info) |> elem(1)
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

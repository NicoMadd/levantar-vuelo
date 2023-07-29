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

  post "/cierre-vuelo/:vuelo_id" do
    case Vuelos.Registry.find(vuelo_id) do
      [{pid_vuelo, _}] -> response_encoder(conn, 201, cerrar_vuelo(pid_vuelo))
      [] -> response_encoder(conn, 404, "No se encontró el vuelo")
    end
  end

  post "/vuelos" do
    # TODO testear validacion de parametros

    tipo_avion = validar_tipo(conn.body_params["tipo"])
    origen = conn.body_params["origen"]
    destino = conn.body_params["destino"]
    datetime = validar_fecha(conn.body_params["fecha"])
    tiempo_limite = conn.body_params["limite"]

    {:ok, vuelo_id} = Vuelos.DynamicSupervisor.publicar_vuelo(tipo_avion, datetime, origen, destino, tiempo_limite)

    response_encoder(conn, 201, "{\"id\": \"#{vuelo_id}\"}")
  end

  get "/vuelos" do
    response = obtener_datos_todos_los_vuelos()

    response_encoder(conn, 200, response)
  end

  get "/vuelos/:vuelo_id" do
    # TODO testear validacion de parametros
    case Vuelos.Registry.find(vuelo_id) do
      [{pid, _}] -> response_encoder(conn, 200, obtener_datos_vuelo(pid))
      [] -> response_encoder(conn, 404, "")
    end
  end

  match _ do
    response_encoder(conn, 404, "Not Found")
  end

  defp obtener_datos_todos_los_vuelos() do
    Vuelos.Registry.get_all()
    |> Enum.map(fn {_id, pid_vuelo} ->
      GenServer.call(pid_vuelo, :info)
    end)
    |> Enum.map(fn vuelo_state ->
      %{
        id: vuelo_state.id,
        tipo_avion: vuelo_state.tipo_avion,
        fecha_hora_despegue: vuelo_state.fecha_hora_despegue,
        origen: vuelo_state.origen,
        destino: vuelo_state.destino,
        tiempo_oferta: vuelo_state.tiempo_oferta
      }
    end)
    |> Jason.encode()
    |> elem(1)
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

    map = %{
      id: vuelo_info_struct.id,
      tipo_avion: vuelo_info_struct.tipo_avion,
      fecha_hora_despegue: vuelo_info_struct.fecha_hora_despegue,
      origen: vuelo_info_struct.origen,
      destino: vuelo_info_struct.destino,
      tiempo_oferta: vuelo_info_struct.tiempo_oferta,
      asientos: asientos
    }

    Jason.encode(map) |> elem(1)
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

  defp response_encoder(conn, status, json) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, json)
  end

  defp cerrar_vuelo(pid_vuelo) do
    send(pid_vuelo, :cerrar_vuelo)
    %{message: "Se cerró el vuelo"} |> Jason.encode() |> elem(1)
  end

end

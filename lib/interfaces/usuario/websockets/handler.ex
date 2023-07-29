defmodule Usuario.Websocket.Handler do
  @behaviour :cowboy_websocket

  require Usuario.Websocket.Handler
  alias Usuario.Websocket.Registry, as: WsRegistry
  alias Entidades.Usuario.DynamicSupervisor, as: UsuarioSup
  alias Alertas.DynamicSupervisor, as: AlertasSup

  def init(request, _state) do
    {:cowboy_websocket, request, request, %{idle_timeout: :infinity}}
  end

  def websocket_init(state) do
    # Fetch de id del usuario
    # Por el momento se saca del atributo peer del request
    # asumo que es el port del origen de la conexion?
    # %{peer: {_ip, port}} = state

    {:ok, usuario_id} = UsuarioSup.crear_usuario("")

    WsRegistry.register(usuario_id)

    IO.puts("usuario: usuario-#{usuario_id} conectado")

    str_pid = to_string(:erlang.pid_to_list(self()))
    IO.puts("websocket_init: #{str_pid}")

    {:ok, json} = Jason.encode(%{usuario_id: usuario_id})
    {:reply, {:text, json}, Map.put(state, :usuario_id, usuario_id)}
  end

  def websocket_handle({:text, "ping"}, state) do
    {:reply, {:text, "pong"}, state}
  end

  def websocket_handle({:text, json_string}, state) do
    {:ok, json} = Jason.decode(json_string)

    %{usuario_id: usuario_id} = state

    json_response =
      json
      |> Map.get("evento")
      |> handle_message(json, usuario_id)
      |> Jason.encode()
      |> elem(1)

    {:reply, {:text, json_response}, state}
  end

  def websocket_info({:broadcast, message}, state) do
    stime = String.slice(Time.to_iso8601(Time.utc_now()), 0, 8)
    {:ok, json} = Jason.encode(%{time: stime, message: message})
    {:reply, {:text, json}, state}
  end



  # def notificar(mensaje) do
  #   Aerolinea.Websocket.Registry
  #   |> Registry.dispatch("usuarios", fn entries ->
  #     for {pid, _} <- entries, do: send(pid, {:broadcast, mensaje})
  #   end)
  # end

  def notificar(mensaje, id_usuario) do
    {:ok, pid} = WsRegistry.find_usuario_pid(id_usuario)
    send(pid, {:broadcast, mensaje})
  end

  def cantidad() do
    Aerolinea.Websocket.Registry
    |> Registry.count()
  end

  # nueva alerta
  defp handle_message("nueva_alerta", json, usuario_id) do
    type = Map.get(json, "type")
    value = Map.get(json, "value")

    nueva_alerta(type, value, usuario_id)
  end

  defp nueva_alerta(type, value, usuario_id) do

    case type do
      "mes" -> AlertasSup.crear_alerta_por_mes(usuario_id, value)
      "destino" -> AlertasSup.crear_alerta_por_destino(usuario_id, value)
      "origen" -> AlertasSup.crear_alerta_por_origen(usuario_id, value)
      "fecha" -> AlertasSup.crear_alerta_por_fecha(usuario_id, value)
      _ -> {}
    end

    %{message: "Nueva alerta creada para el usuario #{usuario_id}"}
  end

  # asignar asientos
  # defp handle_message("asignar_asientos", json, usuario_id) do
  #   asientos = Map.get(json, "asientos")

  #   case Reservas.Registry.find_reserva_by_vuelo(vuelo_id) do
  #     [{pid, _}] -> reservar(pid, usuario_id)
  #     [] -> vuelo_no_encontrado()
  #   end
  # end

  # reserva
  defp handle_message("reserva", json, usuario_id) do
    vuelo_id = Map.get(json, "vuelo_id")

    case Reservas.Registry.find_reserva_by_vuelo(vuelo_id) do
      [{pid, _}] -> reservar(pid, usuario_id, vuelo_id)
      [] -> vuelo_no_encontrado(vuelo_id)
    end
  end

  defp reservar(pid, usuario_id, vuelo_id) do
    GenServer.call(pid, {:reservar, usuario_id})
    %{message: "Reserva realizada al vuelo #{vuelo_id} por el usuario #{usuario_id}"}
  end

  defp vuelo_no_encontrado(vuelo_id) do
    %{message: "Vuelo #{vuelo_id} no encontrado"}
  end

  defp handle_message(evento, _json) do
    %{message: "El evento #{evento} no existe"}
  end
end

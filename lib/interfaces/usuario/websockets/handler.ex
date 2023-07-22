defmodule Usuario.Websocket.Handler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    {:cowboy_websocket, request, request, %{idle_timeout: :infinity}}
  end

  def websocket_init(state) do
    # Fetch de id del usuario
    # Por el momento se saca del atributo peer del request
    # asumo que es el port del origen de la conexion?
    %{peer: {_ip, port}} = state

    Usuario.Websocket.Registry
    |> Registry.register("usuarios", {port})

    IO.puts("usuario: usuario-#{port} conectado")

    str_pid = to_string(:erlang.pid_to_list(self()))
    IO.puts("websocket_init: #{str_pid}")

    {:ok, json} = Jason.encode(%{usuario_id: port})
    {:reply, {:text, json}, state}
  end

  def websocket_handle({:text, json_string}, state) do
    {:ok, json} = Jason.decode(json_string)

    json_response =
      Jason.decode(json_string)
      |> elem(1)
      |> Map.get("evento")
      |> handle_message(json)
      |> Jason.encode()
      |> elem(1)

    {:reply, {:text, json_response}, state}
  end

  def websocket_info({:broadcast, message}, state) do
    stime = String.slice(Time.to_iso8601(Time.utc_now()), 0, 8)
    {:ok, json} = Jason.encode(%{time: stime, message: message})
    {:reply, {:text, json}, state}
  end

  def notificar(mensaje) do
    Aerolinea.Websocket.Registry
    |> Registry.dispatch("usuarios", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:broadcast, mensaje})
    end)
  end

  def notificar(mensaje, id_usuario) do
    Aerolinea.Websocket.Registry
    |> Registry.match("usuarios", {id_usuario})
    |> Enum.each(fn {pid, _} -> send(pid, {:broadcast, mensaje}) end)
  end

  def cantidad() do
    Aerolinea.Websocket.Registry
    |> Registry.count()
  end

  defp handle_message("nueva_alerta", _json) do
    %{message: "Nueva alerta"}
  end

  defp handle_message(evento, _json) do
    %{message: "El evento #{evento} no existe"}
  end
end

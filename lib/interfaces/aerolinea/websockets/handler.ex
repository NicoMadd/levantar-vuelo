defmodule Aerolinea.Websocket.Handler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    {:cowboy_websocket, request, request, %{idle_timeout: :infinity}}
  end

  def websocket_init(state) do
    # Fetch de id del usuario
    # Por el momento se saca del atributo peer del request
    # asumo que es el port del origen de la conexion?
    %{peer: {_ip, port}} = state

    Aerolinea.Websocket.Registry
    |> Registry.register("aerolineas", {port})

    IO.puts("aerolinea: aerolinea-#{port} conectada")

    str_pid = to_string(:erlang.pid_to_list(self()))
    IO.puts("websocket_init: #{str_pid}")

    stime = String.slice(Time.to_iso8601(Time.utc_now()), 0, 8)
    {:ok, json} = Jason.encode(%{time: stime})
    {:reply, {:text, json}, state}
  end

  def websocket_handle({:text, json}, state) do
    {:reply, {:text, json}, state}
  end

  def websocket_info({:broadcast, message}, state) do
    stime = String.slice(Time.to_iso8601(Time.utc_now()), 0, 8)
    {:ok, json} = Jason.encode(%{time: stime, message: message})
    {:reply, {:text, json}, state}
  end

  def alertar(mensaje) do
    Aerolinea.Websocket.Registry
    |> Registry.dispatch("aerolineas", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:broadcast, mensaje})
    end)
  end

  def alertar(mensaje, id_usuario) do
    Aerolinea.Websocket.Registry
    |> Registry.match("aerolineas", {id_usuario})
    |> Enum.each(fn {pid, _} -> send(pid, {:broadcast, mensaje}) end)
  end

  def cantidad() do
    Aerolinea.Websocket.Registry
    |> Registry.count()
  end
end

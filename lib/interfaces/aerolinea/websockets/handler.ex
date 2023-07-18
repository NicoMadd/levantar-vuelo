defmodule Aerolinea.Websocket.Handler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    {:cowboy_websocket, request, nil, %{idle_timeout: :infinity}}
  end

  def websocket_init(state) do
    # Aerolinea.Websocket.Registry |> Registry.register("stock_ticker", {})
    str_pid = to_string(:erlang.pid_to_list(self()))
    IO.puts("websocket_init: #{str_pid}")

    stime = String.slice(Time.to_iso8601(Time.utc_now()), 0, 8)
    {:ok, json} = Jason.encode(%{time: stime})
    {:reply, {:text, json}, state}
  end

  def websocket_handle({:text, json}, state) do
    {:reply, {:text, json <> "asd"}, state}
  end

  def websocket_info(:broadcast, state) do
    stime = String.slice(Time.to_iso8601(Time.utc_now()), 0, 8)
    {:ok, json} = Jason.encode(%{time: stime})
    {:reply, {:text, json}, state}
  end
end

defmodule Node.Observer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # https://erlang.org/doc/man/net_kernel.html#monitor_nodes-1
    :net_kernel.monitor_nodes(true, node_type: :visible)

    {:ok, state}
  end

  def handle_info({:nodedown, node, _node_type}, state) do
    :telemetry.execute(
      [:node, :event, :down],
      %{node_affected: node},
      %{}
    )

    {:noreply, state}
  end

  def handle_info({:nodeup, node, _node_type}, state) do
    :telemetry.execute(
      [:node, :event, :up],
      %{node_affected: node},
      %{}
    )

    IO.puts("asd")

    {:noreply, state}
  end
end

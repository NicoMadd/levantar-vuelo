defmodule Aerolinea do
  use GenServer
  require Logger

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :aerolinea_interface_worker)
  end

  def init(_init_arg) do
    {:ok, []}
  end
end

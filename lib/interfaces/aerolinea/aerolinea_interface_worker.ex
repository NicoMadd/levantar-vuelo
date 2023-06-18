defmodule Aerolinea.Interface.Worker do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :aerolinea_interface_worker)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  def publicar_vuelo() do
  end
end

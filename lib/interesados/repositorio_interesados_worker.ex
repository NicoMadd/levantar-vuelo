defmodule Interesados.Worker do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :interesados_worker)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  def handle_call({:agregar, [nombre, interesado]}, _from, interesados) do
    newRepo = [[nombre, interesado] | interesados]
    {:reply, newRepo, newRepo}
  end

  def handle_call(:get_all, _from, interesados) do
    {:reply, interesados, interesados}
  end

  def agregar(pid, nombre, interesado) do
    GenServer.call(pid, {:agregar, [nombre, interesado]})
  end

  def get_all(pid) do
    GenServer.call(pid, :get_all)
  end
end

defmodule Alertas.DB do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Client

  def crear_alerta_por_mes(usuario_id, mes) do
    Agent.update(__MODULE__, fn s ->
      Map.update(s, mes, [usuario_id], fn users -> [usuario_id | users] end)
    end)
  end

  # def crear_alerta_por_fecha(usuario_id, fecha) do
  #   GenServer.call(pid, {:crear_por_fecha, {usuario_id, fecha}})
  # end

  # def crear_alerta_por_origen(usuario_id, origen) do
  #   GenServer.call(pid, {:crear_por_origen, {usuario_id, origen}})
  # end

  # def crear_alerta_por_destino(usuario_id, destino) do
  #   GenServer.call(pid, {:crear_por_destino, {usuario_id, destino}})
  # end

  def get_all do
    Agent.get(__MODULE__, fn s -> s end)
  end
end

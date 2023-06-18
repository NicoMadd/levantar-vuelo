defmodule Alertas.DB do
  use Agent

  def start_link(_initial_value) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Client

  def crear_alerta_por_mes(usuario_id, mes) do
    Agent.update(__MODULE__, fn s ->
      Map.update(s, mes, [usuario_id], fn users -> Enum.uniq([usuario_id | users]) end)
    end)
  end

  # def crear_alerta_por_fecha(usuario_id, fecha) do
  #   GenServer.call(pid, {:crear_por_fecha, {usuario_id, fecha}})
  # end

  def crear_alerta_por_origen(usuario_id, origen) do
    Agent.update(__MODULE__, fn s ->
      Map.update(s, origen, [usuario_id], fn users -> Enum.uniq([usuario_id | users]) end)
    end)
  end

  def crear_alerta_por_destino(usuario_id, destino) do
    Agent.update(__MODULE__, fn s ->
      Map.update(s, destino, [usuario_id], fn users -> Enum.uniq([usuario_id | users]) end)
    end)
  end

  def remover_alerta_por_mes(usuario_id, mes) do
    Agent.update(__MODULE__, fn s ->
      Map.update(s, mes, [usuario_id], fn users -> List.delete(users, usuario_id) end)
    end)
  end

  def remover_alerta_por_origen(usuario_id, origen) do
    Agent.update(__MODULE__, fn s ->
      Map.update(s, origen, [usuario_id], fn users -> List.delete(users, usuario_id) end)
    end)
  end

  def remover_alerta_por_destino(usuario_id, destino) do
    Agent.update(__MODULE__, fn s ->
      Map.update(s, destino, [usuario_id], fn users -> List.delete(users, usuario_id) end)
    end)
  end

  def get_all do
    Agent.get(__MODULE__, fn s -> s end)
  end
end

defmodule Alertas.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(_init) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(alerta_id) do
    spec = {Alerta, alerta_id}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # Cliente

  def crear_alerta(usuario_id, mes) do
    {:ok, pid} = Alertas.Registry.find_or_create_alerta(mes)
    Alerta.suscribir(pid, usuario_id)
  end
end

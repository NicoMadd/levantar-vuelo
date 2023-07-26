defmodule Entidades.Usuario.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(_init) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(nombre) do
    spec = {Usuario, {nombre}}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def crear_usuario(nombre) do
    start_child(nombre)
  end
end

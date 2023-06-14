defmodule Reservas.DB do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Client

  # Crea una reserva a un vuelo de un usuario en particular.
  def crear_reserva(vuelo_id, usuario_id) do
  end

  # Dada una reserva la cancela. Considerar si debe ser baja logica o baja definitiva.
  def cancelar_reserva(reserva_id, usuario_id) do
  end

  def get_all do
    Agent.get(__MODULE__, fn s -> s end)
  end
end

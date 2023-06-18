defmodule Reservas.DB do
  use Agent

  def start_link(_initial_value) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Client

  # Crea una reserva a un vuelo de un usuario en particular.
  def crear_reserva(vuelo_id, usuario_id) do
    # Generar id de reserva
    reserva_id = App.Utils.generate_id()

    # Crear reserva
    reserva = {vuelo_id, usuario_id}

    Agent.update(__MODULE__, fn reservas ->
      Map.update(reservas, reserva_id, reserva, fn _ -> reserva end)
    end)

    reserva_id
  end

  # Dada una reserva la cancela. Considerar si debe ser baja logica o baja definitiva.
  def cancelar_reserva(reserva_id, usuario_id) do
  end

  def get(reserva_id) do
    Agent.get(__MODULE__, fn reservas -> Map.get(reservas, reserva_id) end)
  end

  def get_all do
    Agent.get(__MODULE__, fn s -> s end)
  end

  def get_usuarios_by_vuelo(vuelo_id) do
    Agent.get(__MODULE__, fn s -> s end)
    |> Enum.filter(fn {_, {vuelo, _}} -> vuelo == vuelo_id end)
    |> Enum.map(fn {_, {_, usuario}} -> usuario end)
  end
end

defmodule Vuelos.Asientos.Builder do


  def build(:embraer190) do
    for row <- 1..26, c <- ?A..?D do
      column = <<c :: utf8>>
      %Asiento{
        numero: "#{row}#{column}",
        fila: row,
        columna: column,
        disponible?: true,
        pasajero: nil
      }
    end
  end

  def build(:boeing737) do
    for row <- 1..38, c <- ?A..?F do
      column = <<c :: utf8>>
      %Asiento{
        numero: "#{row}#{column}",
        fila: row,
        columna: column,
        disponible?: true,
        pasajero: nil
      }
    end
  end

end

# Vuelos.Aeronave.build(:embraer190)
# Vuelos.Aeronave.build(:boeing737)

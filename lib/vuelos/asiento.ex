defmodule Asiento do
  defstruct [:numero, :fila, :columna, :disponible?, :pasajero]
  @type t :: %__MODULE__{numero: String.t(), fila: non_neg_integer, columna: String.t(), disponible?: boolean, pasajero: String.t()}
end

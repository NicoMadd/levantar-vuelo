defmodule VueloState do
  defstruct [:id, :tipo_avion, :tiempo_oferta, :fecha_hora_despegue, :origen, :destino, :asientos]
  # @type t :: %__MODULE__{tipo_avion: atom, tiempo_oferta: DateTime.t(), fecha_hora_D}
end

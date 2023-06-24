defmodule Init do
  @moduledoc """
  Modulo creado para simplificar la inicializacion de situaciones. Por ejemplo, creacion de alertas y vuelos para
  testing de integracion.
  """

  @doc """
  Initializa vuelos
  """
  def init_vuelos() do
    Vuelos.DynamicSupervisor.publicar_vuelo(
      "Boeing",
      10,
      ~U[2023-06-18 00:00:00Z],
      "Buenos Aires",
      "Montevideo",
      10
    )

    Vuelos.DynamicSupervisor.publicar_vuelo(
      "Boeing 2",
      20,
      ~U[2023-05-18 00:00:00Z],
      "Roma",
      "Londres",
      15
    )
  end

  @doc """
  Initializa alertas correspondientes a los vuelos creados arriba
  """
  def init_alertas() do
    Alertas.DynamicSupervisor.crear_alerta_por_mes(1, 2)
    Alertas.DynamicSupervisor.crear_alerta_por_mes(1, 6)
    Alertas.DynamicSupervisor.crear_alerta_por_mes(2, 4)
    Alertas.DynamicSupervisor.crear_alerta_por_mes(2, 5)
    Alertas.DynamicSupervisor.crear_alerta_por_mes(2, 6)

    Alertas.DynamicSupervisor.crear_alerta_por_destino(1, "Londres")
    Alertas.DynamicSupervisor.crear_alerta_por_destino(2, "Londres")

    Alertas.DynamicSupervisor.crear_alerta_por_origen(1, "Buenos Aires")

    Alertas.DynamicSupervisor.crear_alerta_por_fecha(2, ~D[2023-05-18])
  end
end

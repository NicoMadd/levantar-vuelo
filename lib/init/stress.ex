defmodule Stress do
  def stress_1 do
    iniciar_alertas()

    iniciar_vuelos()

    ## TODO iniciar reservas

    ##  TODO asignar asientos
  end

  defp iniciar_alertas() do
    cantidad_usuarios = 1..100
    meses = 1..12
    destinos = ["Londres", "Madrid", "Buenos Aires", "Nueva York"]
    origenes = ["Londres", "Madrid", "Buenos Aires", "Nueva York"]

    meses
    |> Enum.to_list()
    |> Enum.map(fn month -> {month, Enum.to_list(cantidad_usuarios)} end)
    |> Enum.each(fn {month, users} ->
      Enum.each(
        users,
        fn user -> Alertas.DynamicSupervisor.crear_alerta_por_mes(user, month) end
      )
    end)

    destinos
    |> Enum.map(fn city -> {city, Enum.to_list(cantidad_usuarios)} end)
    |> Enum.each(fn {city, users} ->
      Enum.each(
        users,
        fn user -> Alertas.DynamicSupervisor.crear_alerta_por_destino(user, city) end
      )
    end)

    origenes
    |> Enum.map(fn city -> {city, Enum.to_list(cantidad_usuarios)} end)
    |> Enum.each(fn {city, users} ->
      Enum.each(
        users,
        fn user -> Alertas.DynamicSupervisor.crear_alerta_por_origen(user, city) end
      )
    end)

    [~D[2023-05-18], ~D[2023-06-20], ~D[2023-07-20], ~D[2023-08-02]]
    |> Enum.map(fn fecha -> {fecha, Enum.to_list(cantidad_usuarios)} end)
    |> Enum.each(fn {fecha, users} ->
      Enum.each(
        users,
        fn user -> Alertas.DynamicSupervisor.crear_alerta_por_fecha(user, fecha) end
      )
    end)
  end

  defp iniciar_vuelos do
    Vuelos.DynamicSupervisor.publicar_vuelo(
      :boeing737,
      ~U[2023-03-18 00:00:00Z],
      "Roma",
      "Londres",
      30
    )

    Vuelos.DynamicSupervisor.publicar_vuelo(
      :boeing737,
      ~U[2023-05-18 00:00:00Z],
      "Madrid",
      "Nueva York",
      45
    )

    Vuelos.DynamicSupervisor.publicar_vuelo(
      :embraer190,
      ~U[2023-06-18 00:00:00Z],
      "Buenos Aires",
      "Montevideo",
      60
    )
  end
end

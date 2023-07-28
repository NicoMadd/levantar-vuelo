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
      :embraer190,
      ~U[2023-06-18 00:00:00Z],
      "Buenos Aires",
      "Montevideo",
      10
    )

    Vuelos.DynamicSupervisor.publicar_vuelo(
      :boeing737,
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

  def init_alertas2() do
    Alertas.DynamicSupervisor.crear_alerta_por_mes(1, 1)
    Alertas.DynamicSupervisor.crear_alerta_por_mes(1, 3)
    Alertas.DynamicSupervisor.crear_alerta_por_mes(2, 7)
    Alertas.DynamicSupervisor.crear_alerta_por_mes(2, 8)
    Alertas.DynamicSupervisor.crear_alerta_por_mes(2, 9)

    Alertas.DynamicSupervisor.crear_alerta_por_destino(1, "EZE")
    Alertas.DynamicSupervisor.crear_alerta_por_destino(2, "EZE")

    Alertas.DynamicSupervisor.crear_alerta_por_origen(1, "USH")

    Alertas.DynamicSupervisor.crear_alerta_por_fecha(2, ~D[2023-05-18])
  end

  def init_vuelo_y_reservas() do
    {:ok, today} = DateTime.now("Etc/UTC")

    fecha_despegue = DateTime.add(today, 1, :day)

    {:ok, vuelo_id} =  Vuelos.DynamicSupervisor.publicar_vuelo(:embraer190, fecha_despegue, "EZE", "USU", 200)

    [{pid, _}] = Reservas.Registry.find_reserva_by_vuelo(vuelo_id)


    # Reservas.DynamicSupervisor.iniciar_reserva(vuelo_id, 0)
    # Reservas.DynamicSupervisor.iniciar_reserva(vuelo_id, 1)
    # Reservas.DynamicSupervisor.iniciar_reserva(vuelo_id, 2)
    # Reservas.DynamicSupervisor.iniciar_reserva(vuelo_id, 3)
    # Reservas.DynamicSupervisor.iniciar_reserva(vuelo_id, 4)
    # Reservas.DynamicSupervisor.iniciar_reserva(vuelo_id, 5)
    # Reservas.DynamicSupervisor.iniciar_reserva(vuelo_id, 6)
    # Reservas.DynamicSupervisor.iniciar_reserva(vuelo_id, 7)
    {:ok, vuelo_id}
  end

  def crear_usuarios_y_reservar(vuelo_id) do
    {:ok, usuario1} = Entidades.Usuario.DynamicSupervisor.crear_usuario("juan")
    {:ok, usuario2} = Entidades.Usuario.DynamicSupervisor.crear_usuario("pedro")
    {:ok, usuario3} = Entidades.Usuario.DynamicSupervisor.crear_usuario("pablo")

    [{pid, _}] = Reservas.Registry.find_reserva_by_vuelo(vuelo_id)

    GenServer.call(pid, {:reservar, usuario1})
    GenServer.call(pid, {:reservar, usuario2})
    GenServer.call(pid, {:reservar, usuario3})
    
    {:ok, []}
  end

  def cerrar_vuelo(vuelo_id) do
    [{pid, _}] = Vuelos.Registry.find(vuelo_id)

    send(pid, :cerrar_vuelo)
  end

end

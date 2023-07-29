defmodule Alertas.Suscripcion do
  use Task

  def suscribir(usuario_id, {mes, :mes}) do
    IO.puts("suscribiendo en task #{usuario_id} para alerta mes: #{mes}")

    {:ok, pid} = Alertas.Registry.crear_alerta(mes, :mes)
    Alerta.suscribir(pid, usuario_id)

    # :timer.sleep(5000)
    IO.puts("Resultado: #{inspect(pid)}")
  end

  def suscribir(usuario_id, {fecha, :fecha}) do
    IO.puts("suscribiendo en task #{usuario_id} para alerta fecha: #{fecha}")

    {:ok, pid} = Alertas.Registry.crear_alerta(fecha, :fecha)
    Alerta.suscribir(pid, usuario_id)

    # :timer.sleep(5000)
    IO.puts("Resultado: #{inspect(pid)}")
  end

  def suscribir(usuario_id, {origen, :origen}) do
    IO.puts("suscribiendo en task #{usuario_id} para alerta origen: #{origen}")

    {:ok, pid} = Alertas.Registry.crear_alerta(origen, :origen)
    Alerta.suscribir(pid, usuario_id)

    # :timer.sleep(5000)
    IO.puts("Resultado: #{inspect(pid)}")
  end

  def suscribir(usuario_id, {destino, :destino}) do
    IO.puts("suscribiendo en task #{usuario_id} para alerta destino: #{destino}")

    {:ok, pid} = Alertas.Registry.crear_alerta(destino, :destino)
    Alerta.suscribir(pid, usuario_id)

    # :timer.sleep(5000)
    IO.puts("Resultado: #{inspect(pid)}")
  end

end

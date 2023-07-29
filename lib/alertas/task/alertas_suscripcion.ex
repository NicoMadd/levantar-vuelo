defmodule Alertas.Suscripcion do
  use Task

  def suscribir(usuario_id, {mes, :mes}) do
    IO.puts("suscribiendo en task #{usuario_id} para alerta mes: #{mes}")

    case Alertas.Registry.crear_alerta(mes, :mes) do
      {:ok, pid} ->
        Alerta.suscribir(pid, usuario_id)

      {:error, msg} ->
        IO.puts(msg)
    end
  end

  def suscribir(usuario_id, {fecha, :fecha}) do
    IO.puts("suscribiendo en task #{usuario_id} para alerta fecha: #{inspect(fecha)}")

    case Alertas.Registry.crear_alerta(fecha, :fecha) do
      {:ok, pid} ->
        Alerta.suscribir(pid, usuario_id)

      {:error, msg} ->
        IO.inspect(msg)
    end
  end

  def suscribir(usuario_id, {origen, :origen}) do
    IO.puts("suscribiendo en task #{usuario_id} para alerta origen: #{origen}")

    case Alertas.Registry.crear_alerta(origen, :origen) do
      {:ok, pid} ->
        Alerta.suscribir(pid, usuario_id)

      {:error, msg} ->
        IO.inspect(msg)
    end
  end

  def suscribir(usuario_id, {destino, :destino}) do
    IO.puts("suscribiendo en task #{usuario_id} para alerta destino: #{destino}")

    case Alertas.Registry.crear_alerta(destino, :destino) do
      {:ok, pid} ->
        Alerta.suscribir(pid, usuario_id)

      {:error, msg} ->
        IO.inspect(msg)
    end
  end
end

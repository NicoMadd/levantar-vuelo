defmodule Alertas.Worker do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: :alertas_worker)
  end

  # El estado se compone de un map/4
  # que contiene maps con las alertas correspondientes a cada usuario y tipo
  # Los 4 tipos son
  # - Por mes -> mes
  # - Por fecha -> {desde,hasta}
  # - Por origen -> [...origen]
  # - Por destino -> [...destino]
  # Cada uno de estos tipos estara mapeado a su respectivo usuario
  ####
  # Alertas
  #

  def init(_init_arg) do
    {:ok, %{}}
  end

  # Handles

  # def handle_call({:crear_por_mes, {usuario_id, mes_a_alertar}}, _from, alertas) do
  #   {alertas_del_usuario, nuevas_alertas} =
  #     alertas
  #     |> Map.get(:mes, %{})
  #     |> Map.get_and_update(usuario_id, fn
  #       mes ->
  #         case mes do
  #           nil -> {mes_a_alertar, mes_a_alertar}
  #           _ -> {[mes_a_alertar], [mes_a_alertar | mes]}
  #         end
  #     end)

  ## incorporar a nuevas alertas

  #   {:reply, alertas_del_usuario, nuevas_alertas}
  # end

  # Funciones definidas para el cliente

  def crear_alerta_por_mes(_pid, usuario_id, mes) do
    Alertas.DB.crear_alerta_por_mes(usuario_id, mes)
  end
end

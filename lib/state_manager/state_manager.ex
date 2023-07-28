defmodule State.Manager do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> init() end, name: __MODULE__)
  end

  def init do
    Map.new()
  end
end

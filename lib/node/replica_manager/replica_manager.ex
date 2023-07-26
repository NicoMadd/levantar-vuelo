defmodule Replica.Manager do
  use GenServer

  def init(_args) do
    # Get timestamp
    timestamp = Ksuid.generate()
    IO.puts(timestamp)
    {:ok, %{term: timestamp}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
end

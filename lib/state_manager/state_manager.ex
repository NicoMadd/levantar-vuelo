defmodule State.Manager do
  def start_link(_) do
    DeltaCrdt.start_link(DeltaCrdt.AWLWWMap, sync_interval: 3)
  end

  def set_neighbours(crdt, neighbours) do
    DeltaCrdt.set_neighbours(crdt, neighbours)
  end

  def save_state(crdt, key, value) do
    DeltaCrdt.put(crdt, key, value)
  end

  def delete_state(crdt, key) do
    DeltaCrdt.delete(crdt, key)
  end
end

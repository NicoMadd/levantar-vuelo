defmodule Vuelos.Replica.Manager do
  use Replica.Manager

  def start_link() do
    Replica.Manager.start_link([__MODULE__])
  end

  def replicate_to_node(pid, vuelos_id, node) when is_list(vuelos_id) do
  end

  def replicate_from_node(pid, vuelo_id, node) when is_bitstring(vuelo_id) do
  end
end

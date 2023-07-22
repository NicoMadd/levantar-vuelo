defmodule App.Utils do
  def generate_id do
    :crypto.strong_rand_bytes(8) |> Base.encode64()
  end
end

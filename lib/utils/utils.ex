defmodule App.Utils do
  def generate_id do
    :crypto.strong_rand_bytes(8) |> Base.encode64()
  end

  def random_string(n) do
    for _ <- 1..n, into: "", do: <<Enum.random('0123456789abcdef')>>
  end

end

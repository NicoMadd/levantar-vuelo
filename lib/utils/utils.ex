defmodule App.Utils do
  def generate_id do
    :crypto.strong_rand_bytes(8) |> Base.encode64()
  end

  def create_datetime(year, month, day, hour, minute, second) do
    Calendar.NaiveDateTime.from_erl!({{year, month, day}, {hour, minute, second}})
  end
end

defmodule State.Manager.Task do
  def get_state(id_alerta, max_retries, interval, default, after_func) do
    Task.start(fn ->
      retry(
        fn ->
          case DeltaCrdt.get(Node.self(), id_alerta) do
            nil -> {:error, "None found"}
            state -> {:ok, state}
          end
        end,
        max_retries,
        interval,
        default,
        0,
        after_func
      )
    end)
  end

  defp retry(task_fun, max_retries, interval, default, current_retry, after_func) do
    case task_fun.() do
      {:ok, result} ->
        after_func.(result)

      {:error, _reason} ->
        if current_retry < max_retries do
          Process.sleep(interval)
          retry(task_fun, max_retries, interval, default, current_retry + 1, after_func)
        else
          after_func.(default)
        end
    end
  end
end

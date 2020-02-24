defmodule Orange do
  alias Orange.Range

  def range(start, stop, step) do
    Range.range(start, stop, step)
  end

  def for_loop(init, condition, afterthought)
      when is_function(condition, 1) and is_function(afterthought, 1) do
    start_fun =
      if is_function(init, 0) do
        init
      else
        fn -> init end
      end

    next_fun = fn next_item ->
      if condition.(next_item) do
        {
          [next_item],
          afterthought.(next_item)
        }
      else
        {:halt, next_item}
      end
    end

    Stream.resource(start_fun, next_fun, &nop/1)
  end

  defp nop(x), do: x
end

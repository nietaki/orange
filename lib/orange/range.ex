defmodule Orange.Range do
  @enforce_keys [:start, :stop, :step]
  # TODO open closed ends

  defstruct @enforce_keys

  @type t() :: %__MODULE__{
          # TODO not only integers
          start: integer,
          stop: integer,
          step: integer
        }

  @typedoc false
  @type direction :: :up | :down

  @typedoc false
  @type progress :: {next_idx :: integer(), range :: t(), direction()}
end

defimpl Enumerable, for: Orange.Range do
  def reduce(range, acc_tuple, fun) do
    direction =
      case range.step do
        # blowing up on step == 0
        step when step > 0 -> :up
        step when step < 0 -> :down
      end

    do_reduce({0, range, direction}, acc_tuple, fun)
  end

  @spec do_reduce(Orange.Range.progress(), Enumerable.acc(), Enumerable.reducer()) ::
          Enumerable.result()
  defp do_reduce(_progress, {:halt, acc}, _fun) do
    {:halted, acc}
  end

  defp do_reduce(progress, {:suspend, acc}, fun) do
    {:suspended, acc, &do_reduce(progress, &1, fun)}
  end

  defp do_reduce({next_idx, range, direction}, {:cont, acc}, fun) do
    value = range.start + next_idx * range.step

    case {direction, value, range.stop} do
      {:up, value, stop} when value <= stop ->
        do_reduce({next_idx + 1, range, direction}, fun.(value, acc), fun)

      {:down, value, stop} when value >= stop ->
        do_reduce({next_idx + 1, range, direction}, fun.(value, acc), fun)

      _ ->
        {:done, acc}
    end
  end

  def count(_range) do
    # TODO fast implementation
    IO.puts("Range.count")
    {:error, __MODULE__}
  end

  def member?(_range, _element) do
    # TODO fast implementation
    IO.puts("Range.member?")
    {:error, __MODULE__}
  end

  def slice(_range) do
    # TODO fast implementation
    IO.puts("Range.slice")
    {:error, __MODULE__}
  end
end

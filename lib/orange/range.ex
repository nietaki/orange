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
  @type sgn :: :lt | :eq | :gt

  @typedoc false
  @typep direction :: sgn
  @type progress :: {next_idx :: integer(), range :: t(), direction()}

  @doc false
  def direction(%__MODULE__{start: start, stop: stop, step: step}) do
    range_sgn = sgn(stop - start)
    step_sgn = sgn(step)

    case {range_sgn, step_sgn} do
      {_, :eq} ->
        raise ArgumentError, message: "step can't be 0"

      {:eq, sgn} ->
        # bounds are the same, the step has a direction
        sgn

      {sgn, sgn} ->
        # bounds and the step agree
        sgn

      {_, _} ->
        # bounds and the step disagree, empty range
        :eq
    end
  end

  defp sgn(i) when is_integer(i) do
    case i do
      i when i > 0 ->
        :gt

      i when i < 0 ->
        :lt

      _ ->
        :eq
    end
  end

  def range(start, stop, step) do
    ret = %__MODULE__{start: start, stop: stop, step: step}
    # checking the step is valid
    direction(ret)
    ret
  end
end

defimpl Enumerable, for: Orange.Range do
  def reduce(range, acc_tuple, fun) do
    direction = Orange.Range.direction(range)
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
      {:gt, value, stop} when value <= stop ->
        do_reduce({next_idx + 1, range, direction}, fun.(value, acc), fun)

      {:lt, value, stop} when value >= stop ->
        do_reduce({next_idx + 1, range, direction}, fun.(value, acc), fun)

      _ ->
        {:done, acc}
    end
  end

  def count(_range) do
    # TODO fast implementation
    # IO.puts("Range.count")
    # {:ok, div(range.stop - range.start, range.step)}
    {:error, __MODULE__}
  end

  def member?(_range, _element) do
    # TODO fast implementation
    # IO.puts("Range.member?")
    {:error, __MODULE__}
  end

  def slice(_range) do
    # TODO fast implementation
    # IO.puts("Range.slice")
    {:error, __MODULE__}
  end
end

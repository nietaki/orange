defmodule OrangeTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 1000]
  doctest Orange

  describe "build" do
    test "can't build a range with a 0 step" do
      assert_raise ArgumentError, fn ->
        Orange.range(1, 10, 0)
      end
    end
  end

  describe "range |> Enum.to_list()" do
    test "a sample case" do
      rng = Orange.range(3, 5, 1)
      assert Enum.to_list(rng) == [3, 4, 5]
    end

    test "a case with no elements" do
      rng = Orange.range(5, 3, 1)
      assert Enum.to_list(rng) == []
    end

    test "a case going down" do
      rng = Orange.range(5, 3, -1)
      assert Enum.to_list(rng) == [5, 4, 3]
    end

    test "when the range goes up and the step goes down" do
      rng = Orange.range(3, 5, -1)
      # Enum.reduce(rng, fn e, _ -> IO.inspect(e) end)
      assert Enum.to_list(rng) == []
    end

    test "when the range goes down and the step goes up" do
      rng = Orange.range(-3, -5, 1)
      # Enum.reduce(rng, fn e, _ -> IO.inspect(e) end)
      assert Enum.to_list(rng) == []
    end

    test "one-element inclusive range" do
      rng = Orange.range(0, 0, 1)
      # Enum.reduce(rng, fn e, _ -> IO.inspect(e) end)
      assert Enum.to_list(rng) == [0]
    end

    property "gives the same results as a built-in range in simple cases", [:verbose] do
      forall {a, b} <- {small_int(), small_int()} do
        step =
          if b >= a do
            1
          else
            -1
          end

        Enum.to_list(Orange.range(a, b, step)) == Enum.to_list(a..b)
      end
    end

    property "enumerated gives the same results as a for_loop", [:verbose] do
      timeout(
        100,
        forall range <- non_infinite_range() do
          f = range_to_for_loop(range)
          Enum.to_list(range) == Enum.to_list(f)
        end
      )
    end
  end

  describe "range |> Enum.count()" do
    test "a sample case" do
      rng = Orange.range(3, 5, 1)
      assert 3 == Enum.count(rng)
    end

    property "gives the same result as just counting the enumeration" do
      forall range <- non_infinite_range() do
        Enum.count(range) == range |> Enum.to_list() |> Enum.count()
      end
    end
  end

  describe "range |> Enum.member?()" do
    test "member? in a sample case" do
      rng = Orange.range(3, 5, 1)
      assert Enum.member?(rng, 3)
      assert Enum.member?(rng, 4)
      assert Enum.member?(rng, 5)
      refute Enum.member?(rng, 2)
      refute Enum.member?(rng, 6)
    end

    property "gives the same result as checking in the enumerated values" do
      forall {range, value} <- {non_infinite_range(), integer()} do
        is_member = Enum.member?(range, value)
        result = is_member == Enum.member?(Enum.to_list(range), value)

        collect(result, {:member_found, is_member})
      end
    end
  end

  describe "range |> Enum.slice()" do
    test "slice in a sample case" do
      rng = Orange.range(10, 19, 1)
      assert [11, 12, 13] == Enum.slice(rng, 1..3)
    end

    property "gives the same result as checking in the enumerated values" do
      forall range <- non_infinite_range() do
        range_len = Enum.count(range)

        forall {range_start, range_end} <-
                 {int_or_magnitude(range_len), int_or_magnitude(range_len)} do
          slice_range = range_start..range_end
          slice = Enum.slice(range, slice_range)
          enumerated_slice = Enum.slice(Enum.to_list(range), slice_range)
          result = slice == enumerated_slice

          collect(result, {:slice_length, Enum.count(enumerated_slice)})
        end
      end
    end
  end

  describe "for_loop" do
    test "works in a simple case" do
      items =
        Orange.for_loop(1, &(&1 < 10), &(&1 + 1))
        |> Enum.to_list()

      assert Enum.to_list(1..9) == items
    end

    test "works in an exponential case" do
      items =
        Orange.for_loop(1, &(&1 <= 50), &(&1 * 2))
        |> Enum.to_list()

      assert [1, 2, 4, 8, 16, 32] == items
    end

    test "works when the initialization is a function/0" do
      items =
        Orange.for_loop(fn -> 2 - 1 end, &(&1 <= 5), &(&1 + 2))
        |> Enum.to_list()

      assert [1, 3, 5] == items
    end
  end

  def small_int() do
    integer(-1_000_000, 1_000_000)
  end

  def tiny_int() do
    integer(-1_000, 1_000)
  end

  def int_or_magnitude(magnitude) do
    oneof([integer(), integer(-magnitude, magnitude)])
  end

  def non_zero_integer() do
    such_that(i <- integer(), when: i != 0)
  end

  def non_infinite_range() do
    let {a, b, step} <- {small_int(), small_int(), non_zero_integer()} do
      step =
        if b >= a do
          step
        else
          -step
        end

      Orange.range(a, b, step)
    end
  end

  def range_to_for_loop(range) do
    range_sign = sign(range.stop - range.start)
    step_sign = sign(range.step)

    if range_sign * step_sign == -1 do
      []
    else
      condition =
        cond do
          range.stop > range.start ->
            fn value -> value <= range.stop end

          range.stop < range.start ->
            fn value -> value >= range.stop end

          true ->
            fn value -> value == range.stop end
        end

      Orange.for_loop(range.start, condition, &(&1 + range.step))
    end
  end

  defp sign(number) when number > 0, do: 1
  defp sign(number) when number < 0, do: -1
  defp sign(0), do: 0
end

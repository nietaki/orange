defmodule OrangeTest do
  use ExUnit.Case
  doctest Orange

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

  test "count in a sample case" do
    rng = Orange.range(3, 5, 1)
    assert 3 == Enum.count(rng)
  end

  test "member? in a sample case" do
    rng = Orange.range(3, 5, 1)
    assert Enum.member?(rng, 3)
    assert Enum.member?(rng, 4)
    assert Enum.member?(rng, 5)
    refute Enum.member?(rng, 2)
    refute Enum.member?(rng, 6)
  end

  test "slice in a sample case" do
    rng = Orange.range(10, 19, 1)
    assert [11, 12, 13] == Enum.slice(rng, 1..3)
  end
end

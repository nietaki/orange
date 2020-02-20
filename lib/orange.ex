defmodule Orange do
  alias Orange.Range

  def range(start, stop, step) do
    %Range{start: start, stop: stop, step: step}
  end
end

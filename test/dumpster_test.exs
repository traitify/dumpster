defmodule DumpsterTest do
  use ExUnit.Case
  doctest Dumpster

  test "greets the world" do
    assert Dumpster.hello() == :world
  end
end

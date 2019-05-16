defmodule ClijoTest do
  use ExUnit.Case
  doctest Clijo

  test "greets the world" do
    assert Clijo.hello() == :world
  end
end

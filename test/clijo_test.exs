defmodule CliJoTest do
  use ExUnit.Case
  doctest CliJo

  test "greets the world" do
    assert CliJo.hello() == :world
  end
end

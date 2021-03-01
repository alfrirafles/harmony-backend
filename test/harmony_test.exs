defmodule HarmonyTest do
  use ExUnit.Case
  doctest Harmony

  @tag :pending
  test "greets the world" do
    assert Harmony.hello() == :world
  end
end

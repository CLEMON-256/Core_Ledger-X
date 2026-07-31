defmodule LedgerCoreTest do
  use ExUnit.Case
  doctest LedgerCore

  test "greets the world" do
    assert LedgerCore.hello() == :world
  end
end

defmodule Edantic.JsonTest do
  use ExUnit.Case

  alias Edantic.Json

  test "valid?" do
    assert Json.valid?(%{
      "a" => ["b", 1, 4.5],
      "c" => %{"d" => 2}
    })

    refute Json.valid?(:atom)
    refute Json.valid?({"a", "tuple"})
  end

end

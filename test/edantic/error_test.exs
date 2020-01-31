defmodule Edantic.ErrorTest do
  use ExUnit.Case

  alias Edantic.Error
  alias Edantic.Support.Types

  test "format" do
    assert {:error, error} = Edantic.cast(Types, :t_none, {})

    assert s = Error.format(error)
  end
end

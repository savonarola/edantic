defmodule Edantic.CastErrorTest do
  use ExUnit.Case

  alias Edantic.CastError
  alias Edantic.Support.Types

  test "format" do
    {e, t} = Types.t(:t_none)
    assert {:error, error} = Edantic.cast_to_type(e, t, "foo")

    assert s = CastError.format(error)
    assert s =~ "none()"
  end
end

defmodule EdanticTest do
  use ExUnit.Case

  alias Edantic.Support.Types

  test "cast: any()" do
    t = Types.t(:t_any)
    assert {:ok, "foo"} = Edantic.cast_to_type(t, "foo")
  end

  test "cast: none()" do
    t = Types.t(:t_none)
    assert {:error, _} = Edantic.cast_to_type(t, "foo")
  end

  test "cast: atom()" do
    t = Types.t(:t_atom)
    assert {:error, _} = Edantic.cast_to_type(t, "foo")
  end

  test "cast: map()" do
    t = Types.t(:t_map)
    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, 123)
    assert {:error, _} = Edantic.cast_to_type(t, [1, "bar"])

    assert {:ok, %{"foo" => "bar"}} == Edantic.cast_to_type(t, %{"foo" => "bar"})
  end

  test "cast: pid()" do
    t = Types.t(:t_pid)
    assert {:error, _} = Edantic.cast_to_type(t, "foo")
  end

  test "cast: port()" do
    t = Types.t(:t_port)
    assert {:error, _} = Edantic.cast_to_type(t, "foo")
  end

  test "cast: reference()" do
    t = Types.t(:t_reference)
    assert {:error, _} = Edantic.cast_to_type(t, "foo")
  end

  test "cast: struct()" do
    t = Types.t(:t_struct)
    assert {:error, _} = Edantic.cast_to_type(t, "foo")
  end

  test "cast: tuple()" do
    t = Types.t(:t_tuple)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1)
    assert {:ok, {"a", "b", "c"}} = Edantic.cast_to_type(t, ["a", "b", "c"])
  end

  test "cast: float()" do
    t = Types.t(:t_float)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, "123qwe")


    assert {:ok, 1.5} = Edantic.cast_to_type(t, 1.5)
    assert {:ok, 5.0} = Edantic.cast_to_type(t, 5)
    assert {:ok, 123.0} = Edantic.cast_to_type(t, "123")
    assert {:ok, 123.0} = Edantic.cast_to_type(t, "123.0")

  end

  test "cast: integer()" do
    t = Types.t(:t_integer)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, "123qwe")
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, "123.5")

    assert {:ok, 5} = Edantic.cast_to_type(t, 5)
    assert {:ok, 5} = Edantic.cast_to_type(t, 5.0)
    assert {:ok, 123} = Edantic.cast_to_type(t, "123")
    assert {:ok, 123} = Edantic.cast_to_type(t, "123.0")
  end

  test "cast: neg_integer()" do
    t = Types.t(:t_neg_integer)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, "123qwe")
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, "123.5")
    assert {:error, _} = Edantic.cast_to_type(t, 5)

    assert {:ok, -5} = Edantic.cast_to_type(t, -5)
    assert {:ok, -5} = Edantic.cast_to_type(t, -5.0)
    assert {:ok, -123} = Edantic.cast_to_type(t, "-123")
    assert {:ok, -123} = Edantic.cast_to_type(t, "-123.0")
  end


  test "cast: non_neg_integer()" do
    t = Types.t(:t_non_neg_integer)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, "123qwe")
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, "123.5")
    assert {:error, _} = Edantic.cast_to_type(t, -5)

    assert {:ok, 5} = Edantic.cast_to_type(t, 5)
    assert {:ok, 5} = Edantic.cast_to_type(t, 5.0)
    assert {:ok, 123} = Edantic.cast_to_type(t, "123")
    assert {:ok, 123} = Edantic.cast_to_type(t, "123.0")
  end

  test "cast: pos_integer()" do
    t = Types.t(:t_pos_integer)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, "123qwe")
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, "123.5")
    assert {:error, _} = Edantic.cast_to_type(t, -5)
    assert {:error, _} = Edantic.cast_to_type(t, 0)
    assert {:error, _} = Edantic.cast_to_type(t, "0.0")

    assert {:ok, 5} = Edantic.cast_to_type(t, 5)
    assert {:ok, 5} = Edantic.cast_to_type(t, 5.0)
    assert {:ok, 123} = Edantic.cast_to_type(t, "123")
    assert {:ok, 123} = Edantic.cast_to_type(t, "123.0")
  end

  test "cast: list()" do
    t = Types.t(:t_list)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)

    assert {:ok, []} = Edantic.cast_to_type(t, [])
    assert {:ok, [5, :foo]} = Edantic.cast_to_type(t, [5, :foo])
  end

  test "cast: list(integer())" do
    t = Types.t(:t_list_of_integer)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [:foo])
    assert {:error, _} = Edantic.cast_to_type(t, [1.5])

    assert {:ok, []} = Edantic.cast_to_type(t, [])
    assert {:ok, [5]} = Edantic.cast_to_type(t, [5])
    assert {:ok, [5, 6, 7]} = Edantic.cast_to_type(t, [5, 6.0, "7"])
  end

  test "cast: nonempty_list()" do
    t = Types.t(:t_nonempty_list)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [])

    assert {:ok, [5, :foo]} = Edantic.cast_to_type(t, [5, :foo])
  end

  test "cast: nonempty_list(integer())" do
    t = Types.t(:t_nonempty_list_of_integer)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [:foo])
    assert {:error, _} = Edantic.cast_to_type(t, [1.5])
    assert {:error, _} = Edantic.cast_to_type(t, [])

    assert {:ok, [5]} = Edantic.cast_to_type(t, [5])
    assert {:ok, [5, 6, 7]} = Edantic.cast_to_type(t, [5, 6.0, "7"])
  end

  test "cast: maybe_improper_list()" do
    t = Types.t(:t_maybe_improper_list)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)

    assert {:ok, []} = Edantic.cast_to_type(t, [])
    assert {:ok, [5, :foo]} = Edantic.cast_to_type(t, [5, :foo])
  end

  test "cast: maybe_improper_list(integer(), float())" do
    t = Types.t(:t_maybe_improper_list_integer_float)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [:foo])
    assert {:error, _} = Edantic.cast_to_type(t, [2.5, 3.1])

    assert {:ok, 1.5} = Edantic.cast_to_type(t, [1.5])
    assert {:ok, []} = Edantic.cast_to_type(t, [])
    assert {:ok, [5]} = Edantic.cast_to_type(t, [5])
    assert {:ok, [5 | [6 | 7.5]]} = Edantic.cast_to_type(t, [5, 6, 7.5])
  end

end

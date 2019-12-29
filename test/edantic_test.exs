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
    assert {:error, _} = Edantic.cast_to_type(t, "123")
    assert {:error, _} = Edantic.cast_to_type(t, "123.0")

    assert {:ok, 1.5} = Edantic.cast_to_type(t, 1.5)
    assert {:ok, 5.0} = Edantic.cast_to_type(t, 5)
  end

  test "cast: integer()" do
    t = Types.t(:t_integer)

    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, "123")

    assert {:ok, 5} = Edantic.cast_to_type(t, 5)
    assert {:ok, 5} = Edantic.cast_to_type(t, 5.0)
  end

  test "cast: neg_integer()" do
    t = Types.t(:t_neg_integer)

    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, 5)
    assert {:error, _} = Edantic.cast_to_type(t, "123")


    assert {:ok, -5} = Edantic.cast_to_type(t, -5)
    assert {:ok, -5} = Edantic.cast_to_type(t, -5.0)

  end


  test "cast: non_neg_integer()" do
    t = Types.t(:t_non_neg_integer)

    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, -5)
    assert {:error, _} = Edantic.cast_to_type(t, "123")

    assert {:ok, 5} = Edantic.cast_to_type(t, 5)
    assert {:ok, 5} = Edantic.cast_to_type(t, 5.0)

  end

  test "cast: pos_integer()" do
    t = Types.t(:t_pos_integer)

    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, -5)
    assert {:error, _} = Edantic.cast_to_type(t, 0)
    assert {:error, _} = Edantic.cast_to_type(t, "123")


    assert {:ok, 5} = Edantic.cast_to_type(t, 5)
    assert {:ok, 5} = Edantic.cast_to_type(t, 5.0)

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
    assert {:ok, [5, 6, 7]} = Edantic.cast_to_type(t, [5, 6.0, 7])
  end

  test "cast: nonempty_list()" do
    for t <-[Types.t(:t_nonempty_list), Types.t(:t_nonempty_list_lit)] do

      assert {:error, _} = Edantic.cast_to_type(t, "foo")
      assert {:error, _} = Edantic.cast_to_type(t, %{})
      assert {:error, _} = Edantic.cast_to_type(t, 1.5)
      assert {:error, _} = Edantic.cast_to_type(t, [])

      assert {:ok, [5, "foo"]} = Edantic.cast_to_type(t, [5, "foo"])

    end
  end

  test "cast: nonempty_list(integer())" do
    for t <-[Types.t(:t_nonempty_list_of_integer), Types.t(:t_nonempty_list_integer_lit)] do

      assert {:error, _} = Edantic.cast_to_type(t, "foo")
      assert {:error, _} = Edantic.cast_to_type(t, %{})
      assert {:error, _} = Edantic.cast_to_type(t, 1.5)
      assert {:error, _} = Edantic.cast_to_type(t, [1.5])
      assert {:error, _} = Edantic.cast_to_type(t, [])

      assert {:ok, [5]} = Edantic.cast_to_type(t, [5])
      assert {:ok, [5, 6, 7]} = Edantic.cast_to_type(t, [5, 6.0, 7])

    end
  end

  test "cast: maybe_improper_list()" do
    t = Types.t(:t_maybe_improper_list)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)

    assert {:ok, []} = Edantic.cast_to_type(t, [])
    assert {:ok, [5, "foo"]} = Edantic.cast_to_type(t, [5, "foo"])
  end

  test "cast: maybe_improper_list(integer(), float())" do
    t = Types.t(:t_maybe_improper_list_integer_float)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, [5, 6])
  end

  test "cast: maybe_improper_list(integer(), list())" do
    t = Types.t(:t_maybe_improper_list_integer_list)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [2.5, 3.1])

    assert {:ok, []} = Edantic.cast_to_type(t, [])
    assert {:ok, [5]} = Edantic.cast_to_type(t, [5])
    assert {:ok, [5, 6, 7]} = Edantic.cast_to_type(t, [5, 6, 7])
  end

  test "cast: nonempty_improper_list(integer(), float())" do
    t = Types.t(:t_nonempty_improper_list_integer_float)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, [5, 6])
  end

  test "cast: nonempty_improper_list(integer(), list())" do
    t = Types.t(:t_nonempty_improper_list_integer_list)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(t, [])

    assert {:ok, [5, 6]} = Edantic.cast_to_type(t, [5, 6])
  end

  test "cast: nonempty_maybe_improper_list()" do
    t = Types.t(:t_nonempty_maybe_improper_list)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [])

    assert {:ok, [5, "foo"]} = Edantic.cast_to_type(t, [5, "foo"])
  end


  test "cast: nonempty_maybe_improper_list(integer(), float())" do
    t = Types.t(:t_nonempty_maybe_improper_list_integer_float)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, [5, 6])
  end

  test "cast: nonempty_maybe_improper_list(integer(), list())" do
    t = Types.t(:t_nonempty_maybe_improper_list_integer_list)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(t, [])

    assert {:ok, [5, 6]} = Edantic.cast_to_type(t, [5, 6])
  end

  test "cast: atoms" do
    t = Types.t(:t_some_atom)

    assert {:error, _} = Edantic.cast_to_type(t, "bar")
    assert {:ok, :some_atom} = Edantic.cast_to_type(t, "some_atom")

    t = Types.t(:t_true)

    assert {:error, _} = Edantic.cast_to_type(t, "bar")
    assert {:ok, true} = Edantic.cast_to_type(t, true)

    t = Types.t(:t_false)

    assert {:error, _} = Edantic.cast_to_type(t, "bar")
    assert {:ok, false} = Edantic.cast_to_type(t, false)

    t = Types.t(:t_nil)
    assert {:ok, nil} = Edantic.cast_to_type(t, nil)
  end

  test "cast: bins" do
    t = Types.t(:t_empty_bin)

    assert {:error, _} = Edantic.cast_to_type(t, "bar")
    assert {:ok, ""} = Edantic.cast_to_type(t, "")

    t = Types.t(:t_bin)

    assert {:error, _} = Edantic.cast_to_type(t, "bar")
    assert {:ok, "ok"} = Edantic.cast_to_type(t, "ok")
  end


  test "cast: int ranges" do
    t = Types.t(:t_int)

    assert {:error, _} = Edantic.cast_to_type(t, 6)
    assert {:error, _} = Edantic.cast_to_type(t, "5")

    assert {:ok, 5} = Edantic.cast_to_type(t, 5)

    t = Types.t(:t_int_range)

    assert {:error, _} = Edantic.cast_to_type(t, "bar")
    assert {:error, _} = Edantic.cast_to_type(t, 9)
    assert {:error, _} = Edantic.cast_to_type(t, "5")

    assert {:ok, 5} = Edantic.cast_to_type(t, 5)
  end

  test "cast: [integer()]" do
    t = Types.t(:t_list_integer_lit)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)

    assert {:ok, []} = Edantic.cast_to_type(t, [])
    assert {:ok, [5, 6]} = Edantic.cast_to_type(t, [5, 6])
  end

  test "cast: []" do
    t = Types.t(:t_list_empty_lit)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)

    assert {:ok, []} = Edantic.cast_to_type(t, [])
  end

  test "cast: [foo: integer()]" do
    t = Types.t(:t_keyword_list_lit)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, [["quux", 5]])
    assert {:error, _} = Edantic.cast_to_type(t, [["foo", 6.7]])

    assert {:ok, []} = Edantic.cast_to_type(t, [])
    assert {:ok, [foo: 5, bar: 7]} = Edantic.cast_to_type(t, [["foo", 5], ["bar", 7]])
  end

  test "cast: %{}" do
    t = Types.t(:t_map_emply_lit)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, %{a: 1})

    assert {:ok, %{}} = Edantic.cast_to_type(t, %{})
  end

  test "cast: %{key: value_type}" do
    t = Types.t(:t_map_atom_key_lit)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, %{a: 1})
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, %{foo: 1, bar: 2, quux: 3})

    assert {:ok, %{}} = Edantic.cast_to_type(t, %{"foo" => 1, "bar" => 2})
  end

  test "cast: map assocs, required & optional" do
    t = Types.t(:t_map_lit)

    assert {:error, _} = Edantic.cast_to_type(t, "foo")
    assert {:error, _} = Edantic.cast_to_type(t, [])
    assert {:error, _} = Edantic.cast_to_type(t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(t, %{a: 1})
    assert {:error, _} = Edantic.cast_to_type(t, %{})
    assert {:error, _} = Edantic.cast_to_type(t, %{foo: 1, bar: 2, quux: 3})

    assert {:ok, %{}} = Edantic.cast_to_type(t, %{"a" => 1, "b" => [1,2]})
    assert {:ok, %{}} = Edantic.cast_to_type(t, %{"a" => 1, "b" => [1,2], "c" => []})
    assert {:error, _} = Edantic.cast_to_type(t, %{"a" => 1, "c" => []})
  end

  test "cast: map assocs, overlapping" do
    t = Types.t(:t_map_overlapping_lit)

    assert {:ok, %{}} = Edantic.cast_to_type(t, %{"a" => 1, "b" => 1})
    assert {:ok, %{}} = Edantic.cast_to_type(t, %{"a" => 1, "c" => 1})
    assert {:ok, %{}} = Edantic.cast_to_type(t, %{"b" => 1})
    assert {:error, _} = Edantic.cast_to_type(t, %{"a" => 1})

  end
end

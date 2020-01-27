defmodule EdanticTest do
  use ExUnit.Case

  alias Edantic.Support.Types
  alias Edantic.Support.Types.Person

  test "cast: any()" do
    {e, t} = Types.t(:t_any)
    assert {:ok, "foo"} = Edantic.cast_to_type(e, t, "foo")
  end

  test "cast: none()" do
    {e, t} = Types.t(:t_none)
    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
  end

  test "cast: atom()" do
    {e, t} = Types.t(:t_atom)

    _ = :foo
    assert {:ok, :foo} = Edantic.cast_to_type(e, t, "foo")

    assert {:error, _} = Edantic.cast_to_type(e, t, 123)
    assert {:error, _} = Edantic.cast_to_type(e, t, "sdfsadfdsafdsagnsagasgasgd")
  end

  test "cast: map()" do
    {e, t} = Types.t(:t_map)
    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, 123)
    assert {:error, _} = Edantic.cast_to_type(e, t, [1, "bar"])

    assert {:ok, %{"foo" => "bar"}} == Edantic.cast_to_type(e, t, %{"foo" => "bar"})
  end

  test "cast: pid()" do
    {e, t} = Types.t(:t_pid)
    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
  end

  test "cast: port()" do
    {e, t} = Types.t(:t_port)
    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
  end

  test "cast: reference()" do
    {e, t} = Types.t(:t_reference)
    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
  end

  test "cast: struct()" do
    {e, t} = Types.t(:t_struct)
    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
  end

  test "cast: tuple()" do
    {e, t} = Types.t(:t_tuple)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1)
    assert {:ok, {"a", "b", "c"}} = Edantic.cast_to_type(e, t, ["a", "b", "c"])
  end

  test "cast: float()" do
    {e, t} = Types.t(:t_float)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, "123qwe")
    assert {:error, _} = Edantic.cast_to_type(e, t, "123")
    assert {:error, _} = Edantic.cast_to_type(e, t, "123.0")

    assert {:ok, 1.5} = Edantic.cast_to_type(e, t, 1.5)
    assert {:ok, 5.0} = Edantic.cast_to_type(e, t, 5)
  end

  test "cast: integer()" do
    {e, t} = Types.t(:t_integer)

    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, "123")

    assert {:ok, 5} = Edantic.cast_to_type(e, t, 5)
    assert {:ok, 5} = Edantic.cast_to_type(e, t, 5.0)
  end

  test "cast: neg_integer()" do
    {e, t} = Types.t(:t_neg_integer)

    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, 5)
    assert {:error, _} = Edantic.cast_to_type(e, t, "123")

    assert {:ok, -5} = Edantic.cast_to_type(e, t, -5)
    assert {:ok, -5} = Edantic.cast_to_type(e, t, -5.0)
  end

  test "cast: non_neg_integer()" do
    {e, t} = Types.t(:t_non_neg_integer)

    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, -5)
    assert {:error, _} = Edantic.cast_to_type(e, t, "123")

    assert {:ok, 5} = Edantic.cast_to_type(e, t, 5)
    assert {:ok, 5} = Edantic.cast_to_type(e, t, 5.0)
  end

  test "cast: pos_integer()" do
    {e, t} = Types.t(:t_pos_integer)

    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, -5)
    assert {:error, _} = Edantic.cast_to_type(e, t, 0)
    assert {:error, _} = Edantic.cast_to_type(e, t, "123")

    assert {:ok, 5} = Edantic.cast_to_type(e, t, 5)
    assert {:ok, 5} = Edantic.cast_to_type(e, t, 5.0)
  end

  test "cast: list()" do
    {e, t} = Types.t(:t_list)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)

    assert {:ok, []} = Edantic.cast_to_type(e, t, [])
    assert {:ok, [5, :foo]} = Edantic.cast_to_type(e, t, [5, :foo])
  end

  test "cast: list(integer())" do
    {e, t} = Types.t(:t_list_of_integer)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, [:foo])
    assert {:error, _} = Edantic.cast_to_type(e, t, [1.5])

    assert {:ok, []} = Edantic.cast_to_type(e, t, [])
    assert {:ok, [5]} = Edantic.cast_to_type(e, t, [5])
    assert {:ok, [5, 6, 7]} = Edantic.cast_to_type(e, t, [5, 6.0, 7])
  end

  test "cast: nonempty_list()" do
    for {e, t} <- [Types.t(:t_nonempty_list), Types.t(:t_nonempty_list_lit)] do
      assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
      assert {:error, _} = Edantic.cast_to_type(e, t, %{})
      assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
      assert {:error, _} = Edantic.cast_to_type(e, t, [])

      assert {:ok, [5, "foo"]} = Edantic.cast_to_type(e, t, [5, "foo"])
    end
  end

  test "cast: nonempty_list(integer())" do
    for {e, t} <- [Types.t(:t_nonempty_list_of_integer), Types.t(:t_nonempty_list_integer_lit)] do
      assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
      assert {:error, _} = Edantic.cast_to_type(e, t, %{})
      assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
      assert {:error, _} = Edantic.cast_to_type(e, t, [1.5])
      assert {:error, _} = Edantic.cast_to_type(e, t, [])

      assert {:ok, [5]} = Edantic.cast_to_type(e, t, [5])
      assert {:ok, [5, 6, 7]} = Edantic.cast_to_type(e, t, [5, 6.0, 7])
    end
  end

  test "cast: maybe_improper_list()" do
    {e, t} = Types.t(:t_maybe_improper_list)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)

    assert {:ok, []} = Edantic.cast_to_type(e, t, [])
    assert {:ok, [5, "foo"]} = Edantic.cast_to_type(e, t, [5, "foo"])
  end

  test "cast: maybe_improper_list(integer(), float())" do
    {e, t} = Types.t(:t_maybe_improper_list_integer_float)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(e, t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, [5, 6])
  end

  test "cast: maybe_improper_list(integer(), list())" do
    {e, t} = Types.t(:t_maybe_improper_list_integer_list)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, [2.5, 3.1])

    assert {:ok, []} = Edantic.cast_to_type(e, t, [])
    assert {:ok, [5]} = Edantic.cast_to_type(e, t, [5])
    assert {:ok, [5, 6, 7]} = Edantic.cast_to_type(e, t, [5, 6, 7])
  end

  test "cast: nonempty_improper_list(integer(), float())" do
    {e, t} = Types.t(:t_nonempty_improper_list_integer_float)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(e, t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, [5, 6])
  end

  test "cast: nonempty_improper_list(integer(), list())" do
    {e, t} = Types.t(:t_nonempty_improper_list_integer_list)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(e, t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(e, t, [])

    assert {:ok, [5, 6]} = Edantic.cast_to_type(e, t, [5, 6])
  end

  test "cast: nonempty_maybe_improper_list()" do
    {e, t} = Types.t(:t_nonempty_maybe_improper_list)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, [])

    assert {:ok, [5, "foo"]} = Edantic.cast_to_type(e, t, [5, "foo"])
  end

  test "cast: nonempty_maybe_improper_list(integer(), float())" do
    {e, t} = Types.t(:t_nonempty_maybe_improper_list_integer_float)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(e, t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, [5, 6])
  end

  test "cast: nonempty_maybe_improper_list(integer(), list())" do
    {e, t} = Types.t(:t_nonempty_maybe_improper_list_integer_list)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, [2.5, 3.1])
    assert {:error, _} = Edantic.cast_to_type(e, t, [5, 6, 7.5])
    assert {:error, _} = Edantic.cast_to_type(e, t, [])

    assert {:ok, [5, 6]} = Edantic.cast_to_type(e, t, [5, 6])
  end

  test "cast: atoms" do
    {e, t} = Types.t(:t_some_atom)

    assert {:error, _} = Edantic.cast_to_type(e, t, "bar")
    assert {:ok, :some_atom} = Edantic.cast_to_type(e, t, "some_atom")

    {e, t} = Types.t(:t_true)

    assert {:error, _} = Edantic.cast_to_type(e, t, "bar")
    assert {:ok, true} = Edantic.cast_to_type(e, t, true)

    {e, t} = Types.t(:t_false)

    assert {:error, _} = Edantic.cast_to_type(e, t, "bar")
    assert {:ok, false} = Edantic.cast_to_type(e, t, false)

    {e, t} = Types.t(:t_nil)
    assert {:ok, nil} = Edantic.cast_to_type(e, t, nil)
  end

  test "cast: bins" do
    {e, t} = Types.t(:t_empty_bin)

    assert {:error, _} = Edantic.cast_to_type(e, t, "bar")
    assert {:ok, ""} = Edantic.cast_to_type(e, t, "")

    {e, t} = Types.t(:t_bin)

    assert {:error, _} = Edantic.cast_to_type(e, t, "bar")
    assert {:ok, "ok"} = Edantic.cast_to_type(e, t, "ok")
  end

  test "cast: int ranges" do
    {e, t} = Types.t(:t_int)

    assert {:error, _} = Edantic.cast_to_type(e, t, 6)
    assert {:error, _} = Edantic.cast_to_type(e, t, "5")

    assert {:ok, 5} = Edantic.cast_to_type(e, t, 5)

    {e, t} = Types.t(:t_int_range)

    assert {:error, _} = Edantic.cast_to_type(e, t, "bar")
    assert {:error, _} = Edantic.cast_to_type(e, t, 9)
    assert {:error, _} = Edantic.cast_to_type(e, t, "5")

    assert {:ok, 5} = Edantic.cast_to_type(e, t, 5)
  end

  test "cast: [integer()]" do
    {e, t} = Types.t(:t_list_integer_lit)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)

    assert {:ok, []} = Edantic.cast_to_type(e, t, [])
    assert {:ok, [5, 6]} = Edantic.cast_to_type(e, t, [5, 6])
  end

  test "cast: []" do
    {e, t} = Types.t(:t_list_empty_lit)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)

    assert {:ok, []} = Edantic.cast_to_type(e, t, [])
  end

  test "cast: [foo: integer()]" do
    {e, t} = Types.t(:t_keyword_list_lit)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, [["quux", 5]])
    assert {:error, _} = Edantic.cast_to_type(e, t, [["foo", 6.7]])

    assert {:ok, []} = Edantic.cast_to_type(e, t, [])
    assert {:ok, [foo: 5, bar: 7]} = Edantic.cast_to_type(e, t, [["foo", 5], ["bar", 7]])
  end

  test "cast: %{}" do
    {e, t} = Types.t(:t_map_emply_lit)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, %{a: 1})

    assert {:ok, %{}} = Edantic.cast_to_type(e, t, %{})
  end

  test "cast: %{key: value_type}" do
    {e, t} = Types.t(:t_map_atom_key_lit)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, %{a: 1})
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, %{foo: 1, bar: 2, quux: 3})

    assert {:ok, %{}} = Edantic.cast_to_type(e, t, %{"foo" => 1, "bar" => 2})
  end

  test "cast: map assocs, required & optional" do
    {e, t} = Types.t(:t_map_lit)

    assert {:error, _} = Edantic.cast_to_type(e, t, "foo")
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, 1.5)
    assert {:error, _} = Edantic.cast_to_type(e, t, %{a: 1})
    assert {:error, _} = Edantic.cast_to_type(e, t, %{})
    assert {:error, _} = Edantic.cast_to_type(e, t, %{foo: 1, bar: 2, quux: 3})

    assert {:ok, %{}} = Edantic.cast_to_type(e, t, %{"a" => 1, "b" => [1, 2]})
    assert {:ok, %{}} = Edantic.cast_to_type(e, t, %{"a" => 1, "b" => [1, 2], "c" => []})
    assert {:error, _} = Edantic.cast_to_type(e, t, %{"a" => 1, "c" => []})
  end

  test "cast: map assocs, overlapping" do
    {e, t} = Types.t(:t_map_overlapping_lit)

    assert {:ok, %{}} = Edantic.cast_to_type(e, t, %{"a" => 1, "b" => 1})
    assert {:ok, %{}} = Edantic.cast_to_type(e, t, %{"a" => 1, "c" => 1})
    assert {:ok, %{}} = Edantic.cast_to_type(e, t, %{"b" => 1})
    assert {:error, _} = Edantic.cast_to_type(e, t, %{"a" => 1})
  end

  test "cast: {}" do
    {e, t} = Types.t(:t_tuple_empty_lit)

    assert {:error, _} = Edantic.cast_to_type(e, t, {1, 2})
    assert {:ok, {}} = Edantic.cast_to_type(e, t, [])
  end

  test "cast: {:ok, integer()}" do
    {e, t} = Types.t(:t_tuple_lit)

    assert {:error, _} = Edantic.cast_to_type(e, t, ["ok", "123"])
    assert {:ok, {:ok, 123}} = Edantic.cast_to_type(e, t, ["ok", 123])
  end

  test "cast: %St{}" do
    {e, t} = Types.t(:t_st)

    assert {:ok, _} =
             Edantic.cast_to_type(e, t, %{
               "foo" => 4,
               "bar" => [],
               "__struct__" => "Elixir.Edantic.Support.Types.St"
             })
  end

  test "cast: %St{} with constraints" do
    {e, t} = Types.t(:t_st_with_constr)

    assert {:ok, %Types.St{foo: 4, bar: {}}} =
             Edantic.cast_to_type(e, t, %{
               "foo" => 4,
               "bar" => [],
               "__struct__" => "Elixir.Edantic.Support.Types.St"
             })

    assert {:error, _} =
             Edantic.cast_to_type(e, t, %{
               "foo" => 4,
               "bar" => [1, 3],
               "__struct__" => "Elixir.Edantic.Support.Types.St"
             })
  end

  test "cast: %St{} auto" do
    {e, t} = Types.t(:t_st_with_constr)

    assert {:ok, %Types.St{foo: 4, bar: {}}} =
             Edantic.cast_to_type(e, t, %{"foo" => 4, "bar" => []})
  end

  test "cast: user_types" do
    {e, t} = Types.t(:t_user)
    assert {:ok, 4} = Edantic.cast_to_type(e, t, 4)
  end

  test "cast: parametric" do
    {e, t} = Types.t(:t_par_spec)

    assert {:ok, {{:ok, 4}, {:ok, []}}} = Edantic.cast_to_type(e, t, [["ok", 4], ["ok", []]])
  end

  test "cast: term()" do
    {e, t} = Types.t(:t_term)
    assert {:ok, "foo"} = Edantic.cast_to_type(e, t, "foo")
  end

  test "cast: arity()" do
    {e, t} = Types.t(:t_arity)
    assert {:ok, 15} = Edantic.cast_to_type(e, t, 15)

    assert {:error, _} = Edantic.cast_to_type(e, t, 1115)
  end

  test "cast: as_boolean(:ok)" do
    {e, t} = Types.t(:t_as_boolean_ok)
    assert {:ok, :ok} = Edantic.cast_to_type(e, t, "ok")

    assert {:error, _} = Edantic.cast_to_type(e, t, 1115)
  end

  test "cast: bitstring()" do
    {e, t} = Types.t(:t_bitstring)
    assert {:ok, "ok"} = Edantic.cast_to_type(e, t, "ok")

    assert {:error, _} = Edantic.cast_to_type(e, t, 1115)
  end

  test "cast: boolean()" do
    {e, t} = Types.t(:t_boolean)
    assert {:ok, true} = Edantic.cast_to_type(e, t, true)

    assert {:error, _} = Edantic.cast_to_type(e, t, 1115)
  end

  test "cast: byte()" do
    {e, t} = Types.t(:t_byte)
    assert {:ok, 15} = Edantic.cast_to_type(e, t, 15)

    assert {:error, _} = Edantic.cast_to_type(e, t, 1115)
  end

  test "cast: char()" do
    {e, t} = Types.t(:t_char)
    assert {:ok, 1115} = Edantic.cast_to_type(e, t, 1115)

    assert {:error, _} = Edantic.cast_to_type(e, t, 0x11FFFF)
  end

  test "cast: charlist()" do
    {e, t} = Types.t(:t_charlist)
    assert {:ok, [1115]} = Edantic.cast_to_type(e, t, [1115])

    assert {:error, _} = Edantic.cast_to_type(e, t, [0x11FFFF])
  end

  test "cast: nonempty_charlist()" do
    {e, t} = Types.t(:t_nonempty_charlist)
    assert {:ok, [1115]} = Edantic.cast_to_type(e, t, [1115])

    assert {:error, _} = Edantic.cast_to_type(e, t, [0x11FFFF])
    assert {:error, _} = Edantic.cast_to_type(e, t, [])
  end

  test "cast: fun()" do
    {e, t} = Types.t(:t_fun)

    assert {:error, _} = Edantic.cast_to_type(e, t, "")
  end

  test "cast: function()" do
    {e, t} = Types.t(:t_function)

    assert {:error, _} = Edantic.cast_to_type(e, t, "")
  end

  test "cast: identifier()" do
    {e, t} = Types.t(:t_identifier)

    assert {:error, _} = Edantic.cast_to_type(e, t, "")
  end

  test "cast: iolist()" do
    {e, t} = Types.t(:t_iolist)

    assert {:ok, [1, "1", [1, "1"]]} = Edantic.cast_to_type(e, t, [1, "1", [1, "1"]])
    assert {:error, _} = Edantic.cast_to_type(e, t, [1, {1, 3}])
    assert {:error, _} = Edantic.cast_to_type(e, t, "1")
  end

  test "cast: iodata()" do
    {e, t} = Types.t(:t_iodata)

    assert {:ok, [1, "1", [1, "1"]]} = Edantic.cast_to_type(e, t, [1, "1", [1, "1"]])
    assert {:ok, "1"} = Edantic.cast_to_type(e, t, "1")

    assert {:error, _} = Edantic.cast_to_type(e, t, [1, {1, 3}])
  end

  test "cast: keyword()" do
    {e, t} = Types.t(:t_keyword)

    _ = :a
    assert {:ok, [{:a, 5}]} = Edantic.cast_to_type(e, t, [["a", 5]])

    assert {:error, _} = Edantic.cast_to_type(e, t, [[1, 5]])
  end

  test "cast: keyword(integer())" do
    {e, t} = Types.t(:t_keyword_integer)

    _ = :a
    assert {:ok, [{:a, 5}]} = Edantic.cast_to_type(e, t, [["a", 5]])

    assert {:error, _} = Edantic.cast_to_type(e, t, [["a", "b"]])
  end

  test "cast: module()" do
    {e, t} = Types.t(:t_module)

    _ = :foo
    assert {:ok, :foo} = Edantic.cast_to_type(e, t, "foo")

    assert {:error, _} = Edantic.cast_to_type(e, t, 123)
    assert {:error, _} = Edantic.cast_to_type(e, t, "sdfsadfdsafdsagnsagasgasgd")
  end

  test "cast: mfa()" do
    {e, t} = Types.t(:t_mfa)

    _ = :foo
    assert {:ok, {:foo, :foo, 2}} = Edantic.cast_to_type(e, t, ["foo", "foo", 2])

    assert {:error, _} = Edantic.cast_to_type(e, t, ["foo", "bar"])
  end

  test "cast: no_return()" do
    {e, t} = Types.t(:t_no_return)

    assert {:error, _} = Edantic.cast_to_type(e, t, [])
  end

  test "cast: number()" do
    {e, t} = Types.t(:t_number)

    assert {:ok, 1} = Edantic.cast_to_type(e, t, 1)
    assert {:ok, 2.5} = Edantic.cast_to_type(e, t, 2.5)

    assert {:error, _} = Edantic.cast_to_type(e, t, [])
  end

  test "cast: timeout()" do
    {e, t} = Types.t(:t_timeout)

    assert {:ok, 1} = Edantic.cast_to_type(e, t, 1)
    assert {:ok, :infinity} = Edantic.cast_to_type(e, t, "infinity")

    assert {:error, _} = Edantic.cast_to_type(e, t, [])
    assert {:error, _} = Edantic.cast_to_type(e, t, -1)
    assert {:error, _} = Edantic.cast_to_type(e, t, "abc")
  end

  test "cast: node()" do
    {e, t} = Types.t(:t_node)

    _ = :foo
    assert {:ok, :foo} = Edantic.cast_to_type(e, t, "foo")

    assert {:error, _} = Edantic.cast_to_type(e, t, 123)
    assert {:error, _} = Edantic.cast_to_type(e, t, "sdfsadfdsafdsagnsagasgasgd")
  end

  test "cast: common" do
    data = %{
      "age" => 23,
      "name" => ["girolamo", "savonarola"],
      "department" => "it"
    }

    result = %Person{
      age: 23,
      name: {"girolamo", "savonarola"},
      department: :it
    }

    assert {:ok, result} == Edantic.cast(Person, :t, data)

    data_bad_department = %{
      "age" => 23,
      "name" => ["girolamo", "savonarola"],
      "department" => "unknown"
    }

    assert {:error, _} = Edantic.cast(Person, :t, data_bad_department)
  end
end

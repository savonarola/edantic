defmodule Edantic do

  alias Edantic.Json
  alias Code.Typespec

  defstruct [
    module: nil
  ]

  @type t :: %Edantic{}

  def new(module) do
    %Edantic{module: module}
  end

  @spec cast(module, atom, Json.t) :: {:ok, term()} | {:error, term()}
  def cast(module, type, data) do
    if Json.valid?(data) do
      case find_typespec(module, type, 0) do
        {:ok, {typespec, []}} -> cast_to_type(new(module), typespec, data)
        :error -> {:error, "type #{module}.#{type} not found"}
      end
    else
      {:error, "not a valid json"}
    end
  end

  def cast_to_type(e, type, data) do
    # IO.inspect([e, type, data], label: "cast_to_type in")
    res = cast_to_type_real(e, type, data)
    # IO.inspect(res, label: "cast_to_type out")
    res
  end

  # any()
  def cast_to_type_real(_e, {:type, _, :any, _}, data) do
    {:ok, data}
  end

  def cast_to_type_real(_e, {:type, _, :term, _}, data) do
    {:ok, data}
  end

  # none()

  def cast_to_type_real(_e, {:type, _, :none, _} = type, data) do
    {:error, {"cannot cast data to none()", type, data}}
  end

  # atom() and concrete atoms

  def cast_to_type_real(_e, {:atom, _, true}, true) do
    {:ok, true}
  end

  def cast_to_type_real(_e, {:atom, _, false}, false) do
    {:ok, false}
  end

  def cast_to_type_real(_e, {:atom, _, nil}, nil) do
    {:ok, nil}
  end

  def cast_to_type_real(_e, {:atom, _, atom} = type, data) when is_binary(data) do
    if data == to_string(atom) do
      {:ok, atom}
    else
      {:error, {"cannot cast data to atom :#{atom}", type, data}}
    end
  end

  # map()

  def cast_to_type_real(_e, {:type, _, :map, :any}, data) when is_map(data) do
    {:ok, data}
  end

  def cast_to_type_real(_e, {:type, _, :map, []}, data) when data == %{} do
    {:ok, %{}}
  end

  def cast_to_type_real(e, {:type, _, :map, types} = type, %{} = data) when is_list(types) and length(types) > 0 do
    case Edantic.Map.cast_map(e, %{}, types, Map.to_list(data)) do
      {:ok, _} = res -> res
      :error -> {:error, {"cannot cast data to map()", type, data}}
    end
  end

  def cast_to_type_real(_e, {:type, _, :map, _} = type, data) do
    {:error, {"cannot cast data to map()", type, data}}
  end

  # pid()

  def cast_to_type_real(_e, {:type, _, :pid, _} = type, data) do
    {:error, {"cannot cast data to pid()", type, data}}
  end

  # port()

  def cast_to_type_real(_e, {:type, _, :port, _} = type, data) do
    {:error, {"cannot cast data to port()", type, data}}
  end

  # reference()

  def cast_to_type_real(_e, {:type, _, :reference, _} = type, data) do
    {:error, {"cannot cast data to reference()", type, data}}
  end

  # struct()

  def cast_to_type_real(_e, {:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :struct}, _]} = type, data) do
    {:error, {"cannot cast data to struct()", type, data}}
  end

  # tuple()

  def cast_to_type_real(_e, {:type, _, :tuple, :any}, data) when is_list(data) do
    {:ok, List.to_tuple(data)}
  end

  def cast_to_type_real(_e, {:type, _, :tuple, :any} = type, data) do
    {:error, {"cannot cast data to tuple()", type, data}}
  end

  def cast_to_type_real(e, {:type, _, :tuple, types} = type, data) when is_list(data) do
    case cast_tuple(e, [], types, data) do
      {:ok, _} = res -> res
      :error -> {:error, {"cannot cast data to tuple()", type, data}}
    end
  end

  # float()

  def cast_to_type_real(_e, {:type, _, :float, _}, data) when is_number(data) do
    {:ok, data / 1}
  end

  def cast_to_type_real(_e, {:type, _, :float, _} = type, data) do
    {:error, {"cannot cast data to float()", type, data}}
  end

  # integer()

  def cast_to_type_real(_e, {:integer, 0, val} = type, data) do
    cast_to_integer(
      type,
      "integer value(#{val})",
      fn n -> n == val end,
      data
    )
  end

  def cast_to_type_real(_e, {:type, _, :range, [{:integer, _, from}, {:integer, _, to}]} = type, data) do
    cast_to_integer(
      type,
      "integer range (#{from}..#{to})",
      fn n -> n >= from and n <= to end,
      data
    )
  end

  def cast_to_type_real(_e, {:type, _, :integer, _} = type, data) do
    cast_to_integer(
      type,
      "integer()",
      fn _ -> true end,
      data
    )
  end

  # neg_integer()

  def cast_to_type_real(_e, {:type, _, :neg_integer, _} = type, data) do
    cast_to_integer(
      type,
      "neg_integer()",
      fn num -> num < 0 end,
      data
    )
  end

  # non_neg_integer()

  def cast_to_type_real(_e, {:type, _, :non_neg_integer, _} = type, data) do
    cast_to_integer(
      type,
      "non_neg_integer()",
      fn num -> num >= 0 end,
      data
    )
  end

  # pos_integer()

  def cast_to_type_real(_e, {:type, _, :pos_integer, _} = type, data) do
    cast_to_integer(
      type,
      "pos_integer()",
      fn num -> num > 0 end,
      data
    )
  end

  # binaries

  def cast_to_type_real(e, {:type, _, :binary, []}, data) do
    cast_to_type(e, {:type, 0, :binary, [{:integer, 0, 0}, {:integer, 0, 8}]}, data)
  end

  def cast_to_type_real(_e, {:type, _, :binary, [{:integer, _, m}, {:integer, _, n}]} = type, data) when is_binary(data) and m >=0 and n >= 0 do
    var_part_len = bit_size(data) - m
    if var_part_len >= 0 and ((n == 0 and var_part_len == 0) or (n > 0 and rem(var_part_len, n) == 0)) do
      {:ok, data}
    else
      {:error, {"cannot cast data to <<_::#{m}, _::_*#{n}>>", type, data}}
    end
  end

  # list()

  def cast_to_type_real(_e, {:type, _, :nil, []}, []) do
    {:ok, []}
  end

  def cast_to_type_real(_e, {:type, _, :list, []}, data) when is_list(data) do
    {:ok, data}
  end

  def cast_to_type_real(e, {:type, _, :list, [element_type]}, data) when is_list(data) do
    cast_list_to_type(e, element_type, "list()", [], data)
  end

  def cast_to_type_real(_e, {:type, _, :list, _} = type, data) do
    {:error, {"cannot cast data to list()", type, data}}
  end

  # nonempty_list()

  def cast_to_type_real(_e, {:type, _, :nonempty_list, []}, [_ | _] = data) do
    {:ok, data}
  end

  def cast_to_type_real(e, {:type, _, :nonempty_list, [element_type]}, [_ | _] = data) do
    cast_list_to_type(e, element_type, "nonempty_list()", [], data)
  end

  def cast_to_type_real(_e, {:type, _, :nonempty_list, _} = type, data) do
    {:error, {"cannot cast data to nonempty_list()", type, data}}
  end

  # maybe_improper_list()

  def cast_to_type_real(_e, {:type, _, :maybe_improper_list, []}, data) when is_list(data) do
    {:ok, data}
  end

  def cast_to_type_real(e, {:type, _, :maybe_improper_list, [element_type, last_element_type]} = type, data) when is_list(data) do
    case cast_to_type(e, last_element_type, []) do
      {:ok, _} -> cast_list_to_type(e, element_type, "maybe_improper_list()", [], data)
      {:error, _} -> {:error, {"cannot cast data to maybe_improper_list()", type, data}}
    end
  end

  def cast_to_type_real(_e, {:type, _, :maybe_improper_list, _} = type, data) do
    {:error, {"cannot cast data to maybe_improper_list()", type, data}}
  end

  # nonempty_improper_list()

  def cast_to_type_real(e, {:type, _, :nonempty_improper_list, [element_type, last_element_type]} = type, data) when is_list(data) and length(data) > 0 do
    case cast_to_type(e, last_element_type, []) do
      {:ok, _} -> cast_list_to_type(e, element_type, "nonempty_improper_list()", [], data)
      {:error, _} -> {:error, {"cannot cast data to nonempty_improper_list()", type, data}}
    end
  end

  def cast_to_type_real(_e, {:type, _, :nonempty_improper_list, _} = type, data) do
    {:error, {"cannot cast data to nonempty_improper_list()", type, data}}
  end

  # nonempty_maybe_improper_list()

  def cast_to_type_real(_e, {:type, _, :nonempty_maybe_improper_list, []}, data) when is_list(data) and length(data) > 0 do
    {:ok, data}
  end

  def cast_to_type_real(e, {:type, _, :nonempty_maybe_improper_list, [element_type, last_element_type]} = type, data) when is_list(data) and length(data) > 0 do
    case cast_to_type(e, last_element_type, []) do
      {:ok, _} -> cast_list_to_type(e ,element_type, "nonempty_maybe_improper_list()", [], data)
      {:error, _} -> {:error, {"cannot cast data to nonempty_maybe_improper_list()", type, data}}
    end
  end

  def cast_to_type_real(_e, {:type, _, :nonempty_maybe_improper_list, _} = type, data) do
    {:error, {"cannot cast data to nonempty_maybe_improper_list()", type, data}}
  end

  # union

  def cast_to_type_real(e, {:type, _, :union, types} = type, data) do
    case cast_to_one_of(e, types, data) do
      {:ok, _} = res -> res
      :error ->  {:error, {"cannot cast data to union type", type, data}}
    end
  end

  # remote

  def cast_to_type_real(e, {:remote_type, _, [{:atom, _, mod}, {:atom, _, t}, args]}, data) do
    {:ok, {type, vars}} = find_typespec(mod, t, length(args))
    specified_type = Edantic.Spec.specify(type, vars, args)
    cast_to_type(e, specified_type, data)  end

  def cast_to_type_real(e, {:user_type, _, t, args}, data) do
    {:ok, {type, vars}} = find_typespec(e.module, t, length(args))
    specified_type = Edantic.Spec.specify(type, vars, args)
    cast_to_type(e, specified_type, data)
  end

  #############################################################################

  # Shortcuts

  {:type, 213, :binary, []}


  # fallback()

  def cast_to_type_real(_e, type, data) do
    {:error, {"cannot cast data", type, data}}
  end

  #############################################################################


  defp cast_tuple(_e, casted, [], []) do
    {:ok, casted |> Enum.reverse() |> List.to_tuple()}
  end

  defp cast_tuple(e, casted, [type| types], [el | els]) do
    case cast_to_type(e, type, el) do
      {:ok, casted_el} -> cast_tuple(e, [casted_el | casted], types, els)
      {:error, _} -> :error
    end
  end

  defp cast_tuple(_, _, _, _) do
    :error
  end

  defp cast_to_one_of( _, [], _data) do
    :error
  end

  defp cast_to_one_of(e, [type | types], data) do
    case cast_to_type(e, type, data) do
      {:ok, _} = res -> res
      {:error, _} -> cast_to_one_of(e, types, data)
    end
  end

  defp cast_list_to_type(_e, _type, _name, casted, []) do
    {:ok, Enum.reverse(casted)}
  end

  defp cast_list_to_type(e, type, name, casted, [el | rest]) do
    case cast_to_type(e, type, el) do
      {:ok, el_casted} -> cast_list_to_type(e, type, name, [el_casted | casted], rest)
      {:error, error} -> {:error, {"can't cast #{name} element", error}}
    end
  end

  defp cast_to_integer(type, name, valid?, data) when is_number(data) do
    if trunc(data) == data and valid?.(trunc(data)) do
      {:ok, trunc(data)}
    else
      {:error, {"cannot cast data to #{name}", type, data}}
    end
  end

  defp cast_to_integer(type, name, _valid?, data) do
    {:error, {"cannot cast data to #{name}", type, data}}
  end

  def find_typespec(module, type, arity) when is_integer(arity) do
    case Typespec.fetch_types(module) do
      {:ok, types} ->
        case Enum.find(types, fn ({:type, {t, _s, args}}) -> t == type and length(args) == arity end) do
          {_, {_t, spec, args}} -> {:ok, {spec, args}}
          nil -> :error
        end
      _ -> :error
    end
  end
end

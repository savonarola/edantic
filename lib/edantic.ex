defmodule Edantic do
  alias Code.Typespec
  alias Edantic.CastError
  alias Edantic.Error
  alias Edantic.Json

  defstruct module: nil,
            path: []

  @type t() :: %Edantic{}

  @spec new(module) :: Edantic.t()
  def new(module) do
    %Edantic{module: module}
  end

  defmacro cast({{:., _ctx1, [module, type]}, _, []}, data) do
    quote do
      cast(unquote(module), unquote(type), unquote(data))
    end
  end

  defmacro cast(_type, _data) do
    quote do
      error("`Edantic.cast(Module.type(), data)` call expected")
    end
  end

  @spec cast(module, atom, Json.t()) :: {:ok, term()} | {:error, CastError.t() | Error.t()}
  def cast(module, type, data) do
    if Json.valid?(data) do
      case find_typespec(module, type, 0) do
        {:ok, {typespec, []}} ->
          cast_to_type(new(module), typespec, data)

        :error ->
          error("type #{module}.#{type}/0 not found")
      end
    else
      error("not a valid JSON")
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
    cast_error("cannot cast anything to none()", type, data)
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
      cast_error("string does not match the atom", type, data)
    end
  end

  def cast_to_type_real(_e, {:type, _, :atom, []} = type, data) when is_binary(data) do
    {:ok, String.to_existing_atom(data)}
  rescue
    ArgumentError ->
      cast_error("cannot cast string to an unexisting atom", type, data)
  end

  # map()

  def cast_to_type_real(_e, {:type, _, :map, :any}, data) when is_map(data) do
    {:ok, data}
  end

  def cast_to_type_real(_e, {:type, _, :map, []}, data) when data == %{} do
    {:ok, %{}}
  end

  def cast_to_type_real(e, {:type, _, :map, types} = type, %{} = data)
      when is_list(types) and length(types) > 0 do
    case Edantic.Map.cast_map(e, %{}, types, Map.to_list(data)) do
      {:ok, _} = res ->
        res

      :required_keys_missing ->
        cast_error("required key-value pairs are missing in the map", type, data)

      {:bad_key_val, {key, val}} ->
        cast_error("key-value pair does not match to any of the specified for the map", type, %{
          key => val
        })

      {:struct_error, struct_name, e, map} ->
        cast_error("map can't be casted to %#{struct_name}{}: #{e}", type, map)
    end
  end

  def cast_to_type_real(_e, {:type, _, :map, _} = type, data) do
    cast_error("cannot cast this data to map()", type, data)
  end

  # pid()

  def cast_to_type_real(_e, {:type, _, :pid, _} = type, data) do
    cast_error("cannot cast any data to pid()", type, data)
  end

  # port()

  def cast_to_type_real(_e, {:type, _, :port, _} = type, data) do
    cast_error("cannot cast any data to port()", type, data)
  end

  # reference()

  def cast_to_type_real(_e, {:type, _, :reference, _} = type, data) do
    cast_error("cannot cast any data to reference()", type, data)
  end

  # struct()

  def cast_to_type_real(
        _e,
        {:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :struct}, _]} = type,
        data
      ) do
    cast_error("cannot cast data to an unknown struct()", type, data)
  end

  # tuple()

  def cast_to_type_real(_e, {:type, _, :tuple, :any}, data) when is_list(data) do
    {:ok, List.to_tuple(data)}
  end

  def cast_to_type_real(_e, {:type, _, :tuple, :any} = type, data) do
    cast_error("cannot cast non-list data to tuple()", type, data)
  end

  def cast_to_type_real(e, {:type, _, :tuple, types} = type, data) when is_list(data) do
    case cast_tuple(e, [], types, data) do
      {:ok, _} = res ->
        res

      :different_length ->
        cast_error("cannot cast list to a tuple of different size", type, data)

      {:element_error, n, err} ->
        cast_error("cannot cast list element ##{n} to tuple element", type, data, err)
    end
  end

  # float()

  def cast_to_type_real(_e, {:type, _, :float, _}, data) when is_number(data) do
    {:ok, data / 1}
  end

  def cast_to_type_real(_e, {:type, _, :float, _} = type, data) do
    cast_error("cannot cast non-numeric data to float()", type, data)
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

  def cast_to_type_real(
        _e,
        {:type, _, :range, [{:integer, _, from}, {:integer, _, to}]} = type,
        data
      ) do
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

  def cast_to_type_real(e, {:type, _, :binary, []} = type, data) do
    case cast_to_type(e, {:type, 0, :binary, [{:integer, 0, 0}, {:integer, 0, 8}]}, data) do
      {:ok, _} = res -> res
      {:error, _} -> cast_error("cannot cast data to binary()", type, data)
    end
  end

  def cast_to_type_real(
        _e,
        {:type, _, :binary, [{:integer, _, m}, {:integer, _, n}]} = type,
        data
      )
      when is_binary(data) and m >= 0 and n >= 0 do
    var_part_len = bit_size(data) - m

    if var_part_len >= 0 and
         ((n == 0 and var_part_len == 0) or (n > 0 and rem(var_part_len, n) == 0)) do
      {:ok, data}
    else
      cast_error("cannot cast data to binary <<_::#{m}, _::_*#{n}>>", type, data)
    end
  end

  # list()

  def cast_to_type_real(_e, {:type, _, nil, []}, []) do
    {:ok, []}
  end

  def cast_to_type_real(_e, {:type, _, :list, []}, data) when is_list(data) do
    {:ok, data}
  end

  def cast_to_type_real(e, {:type, _, :list, [element_type]}, data) when is_list(data) do
    cast_list_to_type(e, element_type, "list()", data)
  end

  def cast_to_type_real(_e, {:type, _, :list, _} = type, data) do
    cast_error("cannot cast non-list data to list()", type, data)
  end

  # nonempty_list()

  def cast_to_type_real(_e, {:type, _, :nonempty_list, []}, [_ | _] = data) do
    {:ok, data}
  end

  def cast_to_type_real(e, {:type, _, :nonempty_list, [element_type]}, [_ | _] = data) do
    cast_list_to_type(e, element_type, "nonempty_list()", data)
  end

  def cast_to_type_real(_e, {:type, _, :nonempty_list, _} = type, data) do
    cast_error("cannot cast non-list data to nonempty_list()", type, data)
  end

  # maybe_improper_list()

  def cast_to_type_real(_e, {:type, _, :maybe_improper_list, []}, data) when is_list(data) do
    {:ok, data}
  end

  def cast_to_type_real(
        e,
        {:type, _, :maybe_improper_list, [element_type, last_element_type]} = type,
        data
      )
      when is_list(data) do
    case cast_to_type(e, last_element_type, []) do
      {:ok, _} ->
        cast_list_to_type(e, element_type, "maybe_improper_list()", data)

      {:error, _} ->
        cast_error("cannot cast any data to a truly maybe_improper_list()", type, data)
    end
  end

  def cast_to_type_real(_e, {:type, _, :maybe_improper_list, _} = type, data) do
    cast_error("cannot cast any data to maybe_improper_list()", type, data)
  end

  # nonempty_improper_list()

  def cast_to_type_real(
        e,
        {:type, _, :nonempty_improper_list, [element_type, last_element_type]} = type,
        data
      )
      when is_list(data) and length(data) > 0 do
    case cast_to_type(e, last_element_type, []) do
      {:ok, _} ->
        cast_list_to_type(e, element_type, "nonempty_improper_list()", data)

      {:error, _} ->
        cast_error("cannot cast any data to a truly nonempty_improper_list()", type, data)
    end
  end

  def cast_to_type_real(_e, {:type, _, :nonempty_improper_list, _} = type, data) do
    cast_error("cannot cast non-list data to nonempty_improper_list()", type, data)
  end

  # nonempty_maybe_improper_list()

  def cast_to_type_real(_e, {:type, _, :nonempty_maybe_improper_list, []}, data)
      when is_list(data) and length(data) > 0 do
    {:ok, data}
  end

  def cast_to_type_real(
        e,
        {:type, _, :nonempty_maybe_improper_list, [element_type, last_element_type]} = type,
        data
      )
      when is_list(data) and length(data) > 0 do
    case cast_to_type(e, last_element_type, []) do
      {:ok, _} ->
        cast_list_to_type(e, element_type, "nonempty_maybe_improper_list()", data)

      {:error, _} ->
        cast_error("cannot cast any data to a truly nonempty_maybe_improper_list()", type, data)
    end
  end

  def cast_to_type_real(_e, {:type, _, :nonempty_maybe_improper_list, _} = type, data) do
    cast_error("cannot cast non-list data to nonempty_maybe_improper_list()", type, data)
  end

  # union

  def cast_to_type_real(e, {:type, _, :union, types} = type, data) do
    case cast_to_one_of(e, types, data) do
      {:ok, _} = res -> res
      :error -> cast_error("cannot cast data to union type", type, data)
    end
  end

  # remote

  def cast_to_type_real(e, {:remote_type, _, [{:atom, _, mod}, {:atom, _, t}, args]}, data) do
    {:ok, {type, vars}} = find_typespec(mod, t, length(args))
    specified_type = Edantic.Spec.specify(type, vars, args)
    cast_to_type(e, specified_type, data)
  end

  def cast_to_type_real(e, {:user_type, _, t, args}, data) do
    {:ok, {type, vars}} = find_typespec(e.module, t, length(args))
    specified_type = Edantic.Spec.specify(type, vars, args)
    cast_to_type(e, specified_type, data)
  end

  # bitstring

  def cast_to_type_real(_e, {:type, _, :bitstring, []}, data) when is_binary(data) do
    {:ok, data}
  end

  def cast_to_type_real(_e, {:type, _, :bitstring, []} = type, data) do
    cast_error("cannot cast non-binary data to bitstring", type, data)
  end

  # arity

  def cast_to_type_real(_e, {:type, _, :arity, _} = type, data) do
    cast_to_integer(
      type,
      "arity()",
      fn num -> num >= 0 and num <= 255 end,
      data
    )
  end

  # boolean

  def cast_to_type_real(_e, {:type, _, :boolean, []}, true), do: {:ok, true}
  def cast_to_type_real(_e, {:type, _, :boolean, []}, false), do: {:ok, false}

  def cast_to_type_real(_e, {:type, _, :boolean, []} = type, data) do
    cast_error("cannot cast data other than `true` or `false` to boolean", type, data)
  end

  # byte

  def cast_to_type_real(_e, {:type, _, :byte, _} = type, data) do
    cast_to_integer(
      type,
      "byte()",
      fn num -> num >= 0 and num <= 255 end,
      data
    )
  end

  # char

  def cast_to_type_real(_e, {:type, _, :char, _} = type, data) do
    cast_to_integer(
      type,
      "char()",
      fn num -> num >= 0 and num <= 0x10FFFF end,
      data
    )
  end

  # charlist

  def cast_to_type_real(e, {:type, _, :string, _}, data) do
    cast_to_type(e, {:type, 0, :list, [{:type, 0, :char, []}]}, data)
  end

  # nonempty_charlist

  def cast_to_type_real(e, {:type, _, :nonempty_string, _}, data) do
    cast_to_type(e, {:type, 0, :nonempty_list, [{:type, 0, :char, []}]}, data)
  end

  # fun

  def cast_to_type_real(_e, {:type, _, :fun, _} = type, data) do
    cast_error("cannot cast any data to fun", type, data)
  end

  # function

  def cast_to_type_real(_e, {:type, _, :function, _} = type, data) do
    cast_error("cannot cast any data to function", type, data)
  end

  # identifier

  def cast_to_type_real(_e, {:type, _, :identifier, _} = type, data) do
    cast_error("cannot cast any data to identifier", type, data)
  end

  # iolist

  @type t_iolist() :: maybe_improper_list(byte() | binary() | iolist(), binary() | [])

  def cast_to_type_real(e, {:type, _, :iolist, _}, data) do
    {:ok, {iolist_type, _}} = find_typespec(__MODULE__, :t_iolist, 0)
    cast_to_type(e, iolist_type, data)
  end

  # iodata

  @type t_iodata() :: iolist() | binary()

  def cast_to_type_real(e, {:type, _, :iodata, _}, data) do
    {:ok, {iodata_type, _}} = find_typespec(__MODULE__, :t_iodata, 0)
    cast_to_type(e, iodata_type, data)
  end

  # module

  def cast_to_type_real(e, {:type, _, :module, []}, data) do
    cast_to_type(e, {:type, 0, :atom, []}, data)
  end

  # mfa

  @type t_mfa() :: {module(), atom(), arity()}

  def cast_to_type_real(e, {:type, _, :mfa, _}, data) do
    {:ok, {mfa_type, _}} = find_typespec(__MODULE__, :t_mfa, 0)
    cast_to_type(e, mfa_type, data)
  end

  # no_return

  def cast_to_type_real(_e, {:type, _, :no_return, _} = type, data) do
    cast_error("cannot cast any data to no_return", type, data)
  end

  # number

  @type t_number() :: integer() | float()

  def cast_to_type_real(e, {:type, _, :number, _}, data) do
    {:ok, {number_type, _}} = find_typespec(__MODULE__, :t_number, 0)
    cast_to_type(e, number_type, data)
  end

  # timeout

  @type t_timeout() :: :infinity | non_neg_integer()

  def cast_to_type_real(e, {:type, _, :timeout, _}, data) do
    {:ok, {timeout_type, _}} = find_typespec(__MODULE__, :t_timeout, 0)
    cast_to_type(e, timeout_type, data)
  end

  # node

  def cast_to_type_real(e, {:type, _, :node, []}, data) do
    cast_to_type(e, {:type, 0, :atom, []}, data)
  end

  # fallback()

  def cast_to_type_real(_e, type, data) do
    cast_error("cannot cast data", type, data)
  end

  #############################################################################
  defp cast_tuple(e, casted, types, els, n \\ 0)

  defp cast_tuple(_e, casted, [], [], _n) do
    {:ok, casted |> Enum.reverse() |> List.to_tuple()}
  end

  defp cast_tuple(e, casted, [type | types], [el | els], n) do
    case cast_to_type(e, type, el) do
      {:ok, casted_el} -> cast_tuple(e, [casted_el | casted], types, els, n + 1)
      {:error, err} -> {:element_error, n, err}
    end
  end

  defp cast_tuple(_, _, _, _, _) do
    :different_length
  end

  defp cast_to_one_of(_, [], _data) do
    :error
  end

  defp cast_to_one_of(e, [type | types], data) do
    case cast_to_type(e, type, data) do
      {:ok, _} = res -> res
      {:error, _} -> cast_to_one_of(e, types, data)
    end
  end

  defp cast_list_to_type(e, type, name, els) do
    case cast_list_elements_to_type(e, type, 0, [], els) do
      {:ok, _} = res ->
        res

      {:error, n, error} ->
        cast_error("cannot cast list element ##{n} to #{name} element", type, els, error)
    end
  end

  defp cast_list_elements_to_type(_e, _type, _n, casted, []) do
    {:ok, Enum.reverse(casted)}
  end

  defp cast_list_elements_to_type(e, type, n, casted, [el | rest]) do
    case cast_to_type(e, type, el) do
      {:ok, el_casted} -> cast_list_elements_to_type(e, type, n + 1, [el_casted | casted], rest)
      {:error, error} -> {:error, n, error}
    end
  end

  defp cast_to_integer(type, name, valid?, data) when is_number(data) do
    if trunc(data) == data and valid?.(trunc(data)) do
      {:ok, trunc(data)}
    else
      cast_error("cannot cast number to #{name}", type, data)
    end
  end

  defp cast_to_integer(type, name, _valid?, data) do
    cast_error("cannot cast non-numeric data to #{name}", type, data)
  end

  def find_typespec(module, type, arity) when is_integer(arity) do
    case Typespec.fetch_types(module) do
      {:ok, types} ->
        case Enum.find(types, fn {:type, {t, _s, args}} -> t == type and length(args) == arity end) do
          {_, {_t, spec, args}} -> {:ok, {spec, args}}
          nil -> :error
        end

      _ ->
        :error
    end
  end

  def error(message) do
    {:error, Error.new(message)}
  end

  def cast_error(message, type, data, previous_error \\ nil) do
    {:error, CastError.new(message, type, data, previous_error)}
  end
end

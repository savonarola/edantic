defmodule Edantic do

  alias Edantic.Json
  alias Code.Typespec

  @spec cast(module, atom, Json.t) :: {:ok, term()} | {:error, term()}
  def cast(module, type, data) do
    case find_typespec(module, type) do
      {:ok, typespec} -> cast_to_type(typespec, data)
      :error -> {:error, "type #{module}.#{type} not found"}
    end
  end

  # any()
  def cast_to_type({:type, _, :any, _}, data) do
    {:ok, data}
  end

  # none()

  def cast_to_type({:type, _, :none, _} = type, data) do
    {:error, {"cannot cast data to none()", type, data}}
  end

  # atom() and concrete atoms

  def cast_to_type({:atom, _, true}, true) do
    {:ok, true}
  end

  def cast_to_type({:atom, _, false}, false) do
    {:ok, false}
  end

  def cast_to_type({:atom, _, nil}, nil) do
    {:ok, nil}
  end

  def cast_to_type({:atom, _, atom} = type, data) when is_binary(data) do
    if data == to_string(atom) do
      {:ok, atom}
    else
      {:error, {"cannot cast data to atom :#{atom}", type, data}}
    end
  end

  # map()

  def cast_to_type({:type, _, :map, :any}, data) when is_map(data) do
    {:ok, data}
  end

  def cast_to_type({:type, _, :map, []}, data) when data == %{} do
    {:ok, %{}}
  end

  def cast_to_type({:type, _, :map, types} = type, %{} = data) when is_list(types) and length(types) > 0 do
    case cast_map(%{}, types, Map.to_list(data)) do
      {:ok, _} = res -> res
      :error -> {:error, {"cannot cast data to map()", type, data}}
    end
  end

  def cast_to_type({:type, _, :map, _} = type, data) do
    {:error, {"cannot cast data to map()", type, data}}
  end

  # pid()

  def cast_to_type({:type, _, :pid, _} = type, data) do
    {:error, {"cannot cast data to pid()", type, data}}
  end

  # port()

  def cast_to_type({:type, _, :port, _} = type, data) do
    {:error, {"cannot cast data to port()", type, data}}
  end

  # reference()

  def cast_to_type({:type, _, :reference, _} = type, data) do
    {:error, {"cannot cast data to reference()", type, data}}
  end

  # struct()

  def cast_to_type({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :struct}, _]} = type, data) do
    {:error, {"cannot cast data to struct()", type, data}}
  end

  # tuple()

  def cast_to_type({:type, _, :tuple, :any}, data) when is_list(data) do
    {:ok, List.to_tuple(data)}
  end

  def cast_to_type({:type, _, :tuple, :any} = type, data) do
    {:error, {"cannot cast data to tuple()", type, data}}
  end

  def cast_to_type({:type, _, :tuple, types} = type, data) when is_list(data) do
    case cast_tuple([], types, data) do
      {:ok, _} = res -> res
      :error -> {:error, {"cannot cast data to tuple()", type, data}}
    end
  end


  # float()

  def cast_to_type({:type, _, :float, _}, data) when is_number(data) do
    {:ok, data / 1}
  end

  def cast_to_type({:type, _, :float, _} = type, data) do
    {:error, {"cannot cast data to float()", type, data}}
  end

  # integer()

  def cast_to_type({:integer, 0, val} = type, data) do
    cast_to_integer(
      type,
      "integer value(#{val})",
      fn n -> n == val end,
      data
    )
  end

  def cast_to_type({:type, _, :range, [{:integer, _, from}, {:integer, _, to}]} = type, data) do
    cast_to_integer(
      type,
      "integer range (#{from}..#{to})",
      fn n -> n >= from and n <= to end,
      data
    )
  end

  def cast_to_type({:type, _, :integer, _} = type, data) do
    cast_to_integer(
      type,
      "integer()",
      fn _ -> true end,
      data
    )
  end

  # neg_integer()

  def cast_to_type({:type, _, :neg_integer, _} = type, data) do
    cast_to_integer(
      type,
      "neg_integer()",
      fn num -> num < 0 end,
      data
    )
  end

  # non_neg_integer()

  def cast_to_type({:type, _, :non_neg_integer, _} = type, data) do
    cast_to_integer(
      type,
      "non_neg_integer()",
      fn num -> num >= 0 end,
      data
    )
  end

  # pos_integer()

  def cast_to_type({:type, _, :pos_integer, _} = type, data) do
    cast_to_integer(
      type,
      "pos_integer()",
      fn num -> num > 0 end,
      data
    )
  end

  # binaries

  def cast_to_type({:type, _, :binary, [{:integer, _, m}, {:integer, _, n}]} = type, data) when is_binary(data) and m >=0 and n >= 0 do
    var_part_len = bit_size(data) - m
    if var_part_len >= 0 and ((n == 0 and var_part_len == 0) or (n > 0 and rem(var_part_len, n) == 0)) do
      {:ok, data}
    else
      {:error, {"cannot cast data to <<_::#{m}, _::_*#{n}>>", type, data}}
    end
  end

  # list()

  def cast_to_type({:type, _, :nil, []}, []) do
    {:ok, []}
  end

  def cast_to_type({:type, _, :list, []}, data) when is_list(data) do
    {:ok, data}
  end

  def cast_to_type({:type, _, :list, [element_type]}, data) when is_list(data) do
    cast_list_to_type(element_type, "list()", [], data)
  end

  def cast_to_type({:type, _, :list, _} = type, data) do
    {:error, {"cannot cast data to list()", type, data}}
  end

  # nonempty_list()

  def cast_to_type({:type, _, :nonempty_list, []}, [_ | _] = data) do
    {:ok, data}
  end

  def cast_to_type({:type, _, :nonempty_list, [element_type]}, [_ | _] = data) do
    cast_list_to_type(element_type, "nonempty_list()", [], data)
  end

  def cast_to_type({:type, _, :nonempty_list, _} = type, data) do
    {:error, {"cannot cast data to nonempty_list()", type, data}}
  end

  # maybe_improper_list()

  def cast_to_type({:type, _, :maybe_improper_list, []}, data) when is_list(data) do
    {:ok, data}
  end

  def cast_to_type({:type, _, :maybe_improper_list, [element_type, last_element_type]} = type, data) when is_list(data) do
    case cast_to_type(last_element_type, []) do
      {:ok, _} -> cast_list_to_type(element_type, "maybe_improper_list()", [], data)
      {:error, _} -> {:error, {"cannot cast data to maybe_improper_list()", type, data}}
    end
  end

  def cast_to_type({:type, _, :maybe_improper_list, _} = type, data) do
    {:error, {"cannot cast data to maybe_improper_list()", type, data}}
  end

  # nonempty_improper_list()

  def cast_to_type({:type, _, :nonempty_improper_list, [element_type, last_element_type]} = type, data) when is_list(data) and length(data) > 0 do
    case cast_to_type(last_element_type, []) do
      {:ok, _} -> cast_list_to_type(element_type, "nonempty_improper_list()", [], data)
      {:error, _} -> {:error, {"cannot cast data to nonempty_improper_list()", type, data}}
    end
  end

  def cast_to_type({:type, _, :nonempty_improper_list, _} = type, data) do
    {:error, {"cannot cast data to nonempty_improper_list()", type, data}}
  end

  # nonempty_maybe_improper_list()

  def cast_to_type({:type, _, :nonempty_maybe_improper_list, []}, data) when is_list(data) and length(data) > 0 do
    {:ok, data}
  end

  def cast_to_type({:type, _, :nonempty_maybe_improper_list, [element_type, last_element_type]} = type, data) when is_list(data) and length(data) > 0 do
    case cast_to_type(last_element_type, []) do
      {:ok, _} -> cast_list_to_type(element_type, "nonempty_maybe_improper_list()", [], data)
      {:error, _} -> {:error, {"cannot cast data to nonempty_maybe_improper_list()", type, data}}
    end
  end

  def cast_to_type({:type, _, :nonempty_maybe_improper_list, _} = type, data) do
    {:error, {"cannot cast data to nonempty_maybe_improper_list()", type, data}}
  end

  # union

  def cast_to_type({:type, _, :union, types} = type, data) do
    case cast_to_one_of(types, data) do
      {:ok, _} = res -> res
      :error ->  {:error, {"cannot cast data to union type", type, data}}
    end
  end

  # fallback()

  def cast_to_type(type, data) do
    {:error, {"cannot cast data", type, data}}
  end

  #############################################################################

  defp cast_map(casted, types, []) do
    if skipped_required_keys?(casted, types) do
      :error
    else
      map =
        casted
        |> Map.values()
        |> List.flatten()
        |> Map.new()
      {:ok, map}
    end
  end

  defp cast_map(casted, types, [key_val | rest]) do
    matched = cast_map_elem(%{}, types, key_val)
    if Enum.empty?(matched) do
      :error
    else
      new_casted = Map.merge(casted, matched, fn _, kv1, kv2 -> [kv1, kv2] end)
      cast_map(new_casted, types, rest)
    end
  end

  defp skipped_required_keys?(casted, types) do
    Enum.any?(types, fn
      {:type, _, :map_field_exact, _} = t -> not Map.has_key?(casted, t)
      {:type, _, :map_field_assoc, _} -> false
    end)
  end

  defp cast_map_elem(matched, [], _key_val) do
    matched
  end

  defp cast_map_elem(matched, [{:type, _, _assoc_type, [key_type, val_type]} = type | rest], {key, val}) do
    with {:ok, key_casted} <- cast_to_type(key_type, key),
      {:ok, val_casted} <- cast_to_type(val_type, val)
    do
      cast_map_elem(Map.put(matched, type, [{key_casted, val_casted}]), rest, {key, val})
    else
      _ -> cast_map_elem(matched, rest, {key, val})
    end
  end

  defp cast_tuple(casted, [], []) do
    {:ok, casted |> Enum.reverse() |> List.to_tuple()}
  end

  defp cast_tuple(casted, [type| types], [el | els]) do
    case cast_to_type(type, el) do
      {:ok, casted_el} -> cast_tuple([casted_el | casted], types, els)
      {:error, _} -> :error
    end
  end

  defp cast_tuple(_, _, _) do
    :error
  end

  defp cast_to_one_of([], _data) do
    :error
  end

  defp cast_to_one_of([type | types], data) do
    case cast_to_type(type, data) do
      {:ok, _} = res -> res
      {:error, _} -> cast_to_one_of(types, data)
    end
  end

  defp cast_list_to_type(_type, _name, casted, []) do
    {:ok, Enum.reverse(casted)}
  end

  defp cast_list_to_type(type, name, casted, [el | rest]) do
    case cast_to_type(type, el) do
      {:ok, el_casted} -> cast_list_to_type(type, name, [el_casted | casted], rest)
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

  def find_typespec(module, type) do
    case Typespec.fetch_types(module) do
      {:ok, types} ->
        typespecs = for {:type, {^type, spec, args}} <- types, do: {spec, args}
        case typespecs do
          [{typespec, _}] -> {:ok, typespec}
          _ -> :error
        end
      _ -> :error
    end
  end
end

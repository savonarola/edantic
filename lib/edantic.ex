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

  # atom()

  def cast_to_type({:type, _, :atom, _} = type, data) do
    {:error, {"cannot cast data to atom()", type, data}}
  end

  # map()

  def cast_to_type({:type, _, :map, :any}, data) when is_map(data) do
    {:ok, data}
  end


  def cast_to_type({:type, _, :map, :any} = type, data) do
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

  # float()

  def cast_to_type({:type, _, :float, _}, data) when is_number(data) do
    {:ok, data / 1}
  end

  def cast_to_type({:type, _, :float, _} = type, data) when is_binary(data) do
    case Float.parse(data) do
      {number, ""} -> {:ok, number}
      _ -> {:error, {"cannot cast data to float()", type, data}}
    end
  end

  def cast_to_type({:type, _, :float, _} = type, data) do
    {:error, {"cannot cast data to float()", type, data}}
  end

  # integer()

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

  # list()

  def cast_to_type({:type, _, :list, []}, data) when is_list(data) do
    {:ok, data}
  end

  def cast_to_type({:type, _, :list, [element_type]}, data) when is_list(data) do
    cast_list_to_type(element_type, [], data)
  end

  def cast_to_type({:type, _, :list, _} = type, data) do
    {:error, {"cannot cast data to list()", type, data}}
  end

  # nonempty_list()

  def cast_to_type({:type, _, :nonempty_list, []}, [_ | _] = data) do
    {:ok, data}
  end

  def cast_to_type({:type, _, :nonempty_list, [element_type]}, [_ | _] = data) do
    cast_list_to_type(element_type, [], data)
  end

  def cast_to_type({:type, _, :nonempty_list, _} = type, data) do
    {:error, {"cannot cast data to nonempty_list()", type, data}}
  end

  # maybe_improper_list()

  def cast_to_type({:type, _, :maybe_improper_list, []}, data) when is_list(data) do
    {:ok, data}
  end

  def cast_to_type({:type, _, :maybe_improper_list, [element_type, last_element_type]}, data) when is_list(data) do
    cast_maybe_improper_list_to_type(element_type, last_element_type, [], data)
  end

  def cast_to_type({:type, _, :maybe_improper_list, _} = type, data) do
    {:error, {"cannot cast data to maybe_improper_list()", type, data}}
  end

  # fallback()

  def cast_to_type(type, data) do
    {:error, {"cannot cast data", type, data}}
  end

  defp cast_list_to_type(_type, casted, []) do
    {:ok, Enum.reverse(casted)}
  end

  defp cast_list_to_type(type, casted, [el | rest]) do
    case cast_to_type(type, el) do
      {:ok, el_casted} -> cast_list_to_type(type, [el_casted | casted], rest)
      {:error, error} -> {:error, {"can't cast list element", error}}
    end
  end

  def cast_maybe_improper_list_to_type(_, _, _, []) do
    {:ok, []}
  end

  def cast_maybe_improper_list_to_type(element_type, last_element_type, casted, [el]) do
    case cast_to_type(element_type, el) do
      {:ok, casted_el} -> {:ok, Enum.reverse([casted_el | casted])}
      {:error, _} ->
        case cast_to_type(last_element_type, el) do
          {:ok, casted_el} -> {:ok, reverse_improper_list(casted, casted_el)}
          {:error, error} -> {:error, {"can't cast improper list last element", error}}
        end
    end
  end

  def cast_maybe_improper_list_to_type(element_type, last_element_type, casted, [el | rest]) when length(rest) > 0 do
    case cast_to_type(element_type, el) do
      {:ok, casted_el} -> cast_maybe_improper_list_to_type(element_type, last_element_type, [casted_el | casted], rest)
      {:error, error} -> {:error, {"can't cast improper list element", error}}
    end
  end

  defp reverse_improper_list([], res), do: res
  defp reverse_improper_list([head | other], res), do: reverse_improper_list(other, [head | res])

  defp cast_to_integer(type, name, valid?, data) when is_integer(data) do
    if valid?.(data) do
      {:ok, data}
    else
      {:error, {"cannot cast data to #{name}", type, data}}
    end
  end

  defp cast_to_integer(type, name, valid?, data) when is_float(data) do
    if trunc(data) == data and valid?.(trunc(data)) do
      {:ok, trunc(data)}
    else
      {:error, {"cannot cast data to #{name}", type, data}}
    end
  end

  defp cast_to_integer(type, name, valid?, data) when is_binary(data) do
    with {number, ""} <- Float.parse(data),
      true <- trunc(number) == number,
      true <- valid?.(trunc(number))
    do
      {:ok, trunc(number)}
    else
      _ -> {:error, {"cannot cast data to #{name}", type, data}}
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

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

  # fallback()

  def cast_to_type(type, data) do
    {:error, {"cannot cast data", type, data}}
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

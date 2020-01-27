defmodule Edantic.Map do
  @moduledoc false

  def cast_map(_e, casted, types, []) do
    struct_name = find_struct_name(types, casted)

    if struct_name do
      casted
      |> casted_to_map()
      |> try_cast_to_struct(struct_name)
    else
      if missing_required_key?(casted, types) do
        :required_keys_missing
      else
        map = casted_to_map(casted)
        {:ok, map}
      end
    end
  end

  def cast_map(e, casted, types, [key_val | rest]) do
    matched = cast_map_elem(e, %{}, types, key_val)
    if Enum.empty?(matched) do
      {:bad_key_val, key_val}
    else
      new_casted = Map.merge(casted, matched, fn _, kv1, kv2 -> [kv1, kv2] end)
      cast_map(e, new_casted, types, rest)
    end
  end

  defp missing_required_key?(casted, types) do
    Enum.any?(types, fn
      {:type, _, :map_field_exact, _} = t -> not Map.has_key?(casted, t)
      {:type, _, :map_field_assoc, _} -> false
    end)
  end

  defp try_cast_to_struct(map, struct_name) do
    {:ok, struct!(struct_name, map)}
  rescue
    e ->
      {:struct_error, struct_name, e, map}
  end

  defp find_struct_name([], _) do
    nil
  end
  defp find_struct_name([{:type, _, :map_field_exact, [{:atom, _, :__struct__}, {:atom, _, module}]} = type | _types], casted) do
    if not Map.has_key?(casted, type) do
      module
    else
      nil
    end
  end
  defp find_struct_name([_ | types], casted) do
    find_struct_name(types, casted)
  end

  defp casted_to_map(casted) do
    casted
    |> Map.values()
    |> List.flatten()
    |> Map.new()
  end

  def module_exist?(module) do
    function_exported?(module, :__info__, 1)
  end

  defp cast_map_elem(_e, matched, [], _key_val) do
    matched
  end

  defp cast_map_elem(e, matched, [{:type, _, _assoc_type, [key_type, val_type]} = type | rest], {key, val}) do
    with {:ok, key_casted} <- Edantic.cast_to_type(e, key_type, key),
      {:ok, val_casted} <- Edantic.cast_to_type(e, val_type, val)
    do
      cast_map_elem(e, Map.put(matched, type, [{key_casted, val_casted}]), rest, {key, val})
    else
      _ -> cast_map_elem(e, matched, rest, {key, val})
    end
  end

end

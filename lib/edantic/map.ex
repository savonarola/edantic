defmodule Edantic.Map do
  @moduledoc false

  def cast_map(_e, casted, types, []) do
    skipped_keys = skipped_required_keys(casted, types)

    case skipped_keys do
      [] ->
        map = casted_to_map(casted)
        {:ok, map}
      [{:type, _, :map_field_exact, [{:atom, _, :__struct__}, {:atom, _, module}]}] ->
        if module_exist?(module) do
          map =
            casted
            |> casted_to_map()
            |> Map.put(:__struct__, module)
          {:ok, map}
        end
      _ ->
        :error
    end
  end

  def cast_map(e, casted, types, [key_val | rest]) do
    matched = cast_map_elem(e, %{}, types, key_val)
    if Enum.empty?(matched) do
      :error
    else
      new_casted = Map.merge(casted, matched, fn _, kv1, kv2 -> [kv1, kv2] end)
      cast_map(e, new_casted, types, rest)
    end
  end

  defp skipped_required_keys(casted, types) do
    Enum.filter(types, fn
      {:type, _, :map_field_exact, _} = t -> not Map.has_key?(casted, t)
      {:type, _, :map_field_assoc, _} -> false
    end)
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

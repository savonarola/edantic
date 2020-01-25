defmodule Edantic.Spec do
  def specify(type, vars, args) do
    bindings = bind_vars(vars, args)
    specify(type, bindings)
  end

  defp bind_vars(vars, args) do
    vars
    |> Enum.map(fn {:var, _, name} -> name end)
    |> Enum.zip(args)
    |> Map.new()
  end

  defp specify({:var, _, name}, bindings) do
    bindings[name]
  end

  defp specify(list, bindings) when is_list(list) do
    Enum.map(list, fn el -> specify(el, bindings) end)
  end

  defp specify(tuple, bindings) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.map(fn el -> specify(el, bindings) end)
    |> List.to_tuple()
  end

  defp specify(other, _) do
    other
  end
end

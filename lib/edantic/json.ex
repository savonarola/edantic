defmodule Edantic.Json do
  @type key() :: String.t()
  @type value() ::
          String.t()
          | nil
          | boolean
          | integer()
          | float()
          | %{optional(key()) => value()}
          | [value()]
  @type t() :: value()

  def valid?(v) when is_nil(v) or is_boolean(v) or is_number(v) or is_binary(v) do
    true
  end

  def valid?(v) when is_list(v) do
    Enum.all?(v, &valid?/1)
  end

  def valid?(v) when is_map(v) do
    Enum.all?(v, fn {key, value} -> is_binary(key) and valid?(value) end)
  end

  def valid?(_) do
    false
  end
end

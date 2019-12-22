defmodule Edantic.Json do
  @type key :: String.t
  @type value :: String.t | nil | integer | float | %{optional(key) => value} | [value]
  @type t :: %{optional(key) => value}
end

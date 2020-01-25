# Edantic

Eduntic is a library for casting «plain» JSON-originated data into Elixir data structs
with nessesary validations.

## Example

Assume there is a module with a corresponding struct:

```elixir
defmodule Person do
  defstruct [
    :age, :name, :department
  ]

  @type first_name() :: String.t
  @type second_name() :: String.t

  @type t :: %__MODULE__{
    age: non_neg_integer(),
    name: {first_name(), second_name()},
    department: :finance | :it
  }
end
```

And there is some JSON-originated data:

```elixir
data = %{
  "age" => 23,
  "name" => ["girolamo", "savonarola"],
  "department" => "it"
}
```

With Edantic we can simultaneously validate this data and convert into Elixir structures:

```elixir

{:ok, person} = Edantic.cast(Person, :t, data)

person == %Person{
  age: 23,
  name: {"girolamo", "savonarola"},
  department: :it
}
```

## JSON

By «JSON-originated» data is denoted the following type `t`:

```
@type key :: String.t
@type value :: String.t | nil | boolean | integer | float | %{optional(key) => value} | [value]
@type t :: %{optional(key) => value}
```

## Primitive convertions

Since plain data structure is rather poor, there are some automatic enrichments allowed while casting:

* Strings can be casted to corresponding atoms `"a" -> :a`.
* Lists of suitable size can be casted to tuples `[1, "a"] -> {1, :a}`.
* Maps can be casted to arbitrary struct whith the same set of fields `%{a: 123} -> %SomeSt{a: 123}`
if fields pass validations.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `edantic` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:edantic, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/edantic](https://hexdocs.pm/edantic).


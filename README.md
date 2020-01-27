[![Build Status](https://travis-ci.org/savonarola/edantic.svg?branch=master)](https://travis-ci.org/savonarola/edantic)
[![Coverage Status](https://coveralls.io/repos/github/savonarola/edantic/badge.svg?branch=master&1504538909)](https://coveralls.io/github/savonarola/edantic?branch=master)


<a href="https://funbox.ru">
  <img src="http://funbox.ru/badges/sponsored_by_funbox_compact.svg" alt="Sponsored by FunBox" width=250 />
</a>

# Edantic

Eduntic is a library for casting «plain» JSON-originated data into Elixir data structures
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

With Edantic we can simultaneously validate this data and convert it into Elixir structures:

```elixir

{:ok, person} = Edantic.cast(Person, :t, data)

person == %Person{
  age: 23,
  name: {"girolamo", "savonarola"},
  department: :it
}
```

```elixir
data_bad_department = %{
  "age" => 23,
  "name" => ["girolamo", "savonarola"],
  "department" => "unknown"
}

assert {:error, error} = Edantic.cast(Person, :t, data_bad_department)

IO.puts(Edantic.CastError.format(error))
```

```
key-value pair does not match to any of the specified for the map
  data: %{"department" => "unknown"}
  type: %Edantic.Support.Types.Person{age: non_neg_integer(), department: :finance | :it, name: {first_name(), second_name()}}}
```

## JSON

By «JSON-originated data» is denoted all the data matching the following type `t`:

```elixir
@type key :: String.t
@type value :: String.t | nil | boolean | integer | float | %{optional(key) => value} | [value]
@type t :: value
```

## Primitive convertions

Since plain data structures are rather poor, there are some automatic enrichments allowed while casting:

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


defmodule Edantic.Support.Types do

  def t(name) do
    {:ok, {type, []}} = Edantic.find_typespec(__MODULE__, name, 0)
    {Edantic.new(__MODULE__), type}
  end

  @type t_any :: any()

  @type t_none :: none()

  @type t_atom :: atom()

  @type t_map :: map()

  @type t_pid :: pid()

  @type t_port :: port()

  @type t_reference :: reference()

  @type t_struct :: struct()

  @type t_tuple :: tuple()

  @type t_float :: float()

  @type t_integer :: integer()

  @type t_neg_integer :: neg_integer()

  @type t_non_neg_integer :: non_neg_integer()

  @type t_pos_integer :: pos_integer()

  @type t_list :: list()

  @type t_list_of_integer :: list(integer())

  @type t_nonempty_list :: nonempty_list()

  @type t_nonempty_list_of_integer :: nonempty_list(integer())

  @type t_maybe_improper_list :: maybe_improper_list()

  @type t_maybe_improper_list_integer_float :: maybe_improper_list(integer(), float())
  @type t_maybe_improper_list_integer_list :: maybe_improper_list(integer(), list())

  @type t_nonempty_improper_list_integer_float :: nonempty_improper_list(integer(), float())
  @type t_nonempty_improper_list_integer_list :: nonempty_improper_list(integer(), list())

  @type t_nonempty_maybe_improper_list :: nonempty_maybe_improper_list()
  @type t_nonempty_maybe_improper_list_integer_float :: nonempty_maybe_improper_list(integer(), float())
  @type t_nonempty_maybe_improper_list_integer_list :: nonempty_maybe_improper_list(integer(), list())

  @type t_some_atom :: :some_atom
  @type t_true :: true
  @type t_false :: false
  @type t_nil :: nil

  @type t_empty_bin :: <<>>
  @type t_bin :: <<_::7,_::_*9>>

  @type t_int :: 5
  @type t_int_range :: 5..7

  @type t_list_integer_lit :: [integer()]
  @type t_list_empty_lit :: []
  @type t_nonempty_list_lit :: [...]
  @type t_nonempty_list_integer_lit :: [integer(), ...]

  @type t_keyword_list_lit :: [foo: integer(), bar: integer()]

  @type t_map_emply_lit :: %{}
  @type t_map_atom_key_lit :: %{foo: integer(), bar: integer()}
  @type t_map_lit :: %{
    required(:a) => integer(),
    required(:b) => tuple(),
    optional(:c) => list()
  }

  @type t_map_overlapping_lit :: %{required(:a|:b) => 1, required(:b|:c) => 1}

  @type t_tuple_empty_lit :: {}

  @type t_tuple_lit :: {:ok, integer()}

  defmodule St do
    defstruct [
      foo: 4,
      bar: {}
    ]

    @type t :: %__MODULE__{
      foo: integer(),
      bar: {}
    }
  end

  @type t_st :: %St{}
  @type t_st_with_constr :: St.t

  @type t_user :: t_integer()

  defmodule Par do
    @type t(a, b) :: {a, b}
  end

  @type t_par(a) :: {Par.t(a, integer()), Par.t(a, list())}
  @type t_par_spec :: t_par(:ok)

  @type t_term :: term()

  @type t_arity :: arity()

  @type t_as_boolean_ok :: as_boolean(:ok)

  @type t_bitstring() :: bitstring()

  @type t_boolean() :: boolean()

  @type t_byte() :: byte()

  @type t_char() :: char()

  @type t_charlist() :: charlist()

  @type t_nonempty_charlist() :: nonempty_charlist()

  @type t_fun() :: fun()

  @type t_function() :: function()

  @type t_identifier() :: identifier()

  @type t_iolist() :: iolist()

  @type t_iodata() :: iodata()

  @type t_keyword() :: keyword()

  @type t_keyword_integer() :: keyword(integer())

  @type t_module() :: module()

  @type t_mfa() :: mfa()

  @type t_no_return() :: no_return()

  @type t_number() :: number()

  @type t_timeout() :: timeout()

  @type t_node() :: node()

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

end

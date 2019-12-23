defmodule Edantic.Support.Types do

  def t(name) do
    {:ok, type} = Edantic.find_typespec(__MODULE__, name)
    type
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

end

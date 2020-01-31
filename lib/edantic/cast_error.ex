defmodule Edantic.CastError do
  defstruct type: nil,
            data: nil,
            message: "",
            previous_error: nil

  alias __MODULE__, as: CastError

  @type t() :: %CastError{}

  @spec new(String.t(), term(), term(), t() | nil) :: t()
  def new(message, type, data, previous_error \\ nil) do
    %CastError{
      type: type,
      data: data,
      message: message,
      previous_error: previous_error
    }
  end

  @spec format_type(t()) :: String.t()
  def format_type(%CastError{type: type}) do
    {_, _, [_, type_ast]} = Code.Typespec.type_to_quoted({:_, type, []})
    Macro.to_string(type_ast)
  end

  @spec format(t()) :: String.t()
  def format(%CastError{} = error) do
    "#{error.message}\n  data: #{inspect(error.data)}\n  type: #{format_type(error)}}"
  end
end

defmodule Edantic.Error do
  defstruct message: ""

  alias __MODULE__, as: Error

  @type t() :: %Error{
          message: String.t()
        }

  @spec new(String.t()) :: t()
  def new(message) do
    %Error{
      message: message
    }
  end

  @spec format(t()) :: String.t()
  def format(%Error{} = error) do
    error.message
  end
end

defmodule Edantic.Error do
  defstruct message: ""

  alias __MODULE__, as: Error

  @type t() :: %Error{}

  def new(message) do
    %Error{
      message: message
    }
  end
end

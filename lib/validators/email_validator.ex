defmodule EmailValidator do
  @doc """
  Validates an email contains "@" and "."
  """
  @spec valid?(String.t()) :: boolean()
  def valid?(email) when is_binary(email) do
    String.contains?(email, "@") and String.contains?(email, ".")
  end
end

defmodule Void.Tokens do
  def generate_token() do
    Ecto.UUID.generate()
  end
end

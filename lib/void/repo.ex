defmodule Void.Repo do
  use Ecto.Repo,
    otp_app: :void,
    adapter: Ecto.Adapters.Postgres
end

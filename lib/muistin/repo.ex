defmodule Muistin.Repo do
  use Ecto.Repo,
    otp_app: :muistin,
    adapter: Ecto.Adapters.SQLite3
end

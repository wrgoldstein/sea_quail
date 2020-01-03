defmodule SeaQuail.Repo do
  use Ecto.Repo,
    otp_app: :sea_quail,
    adapter: Ecto.Adapters.Postgres
end

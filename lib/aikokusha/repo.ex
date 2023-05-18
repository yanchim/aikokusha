defmodule Aikokusha.Repo do
  use Ecto.Repo,
    otp_app: :aikokusha,
    adapter: Ecto.Adapters.Postgres
end

defmodule Mushcalc.Repo do
  use Ecto.Repo,
    otp_app: :mushcalc,
    adapter: Ecto.Adapters.Postgres
end

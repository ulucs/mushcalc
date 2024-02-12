defmodule Mushcalc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MushcalcWeb.Telemetry,
      # Start the Ecto repository
      Mushcalc.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mushcalc.PubSub},
      # Start Finch
      {Finch, name: Mushcalc.Finch},
      # Start the Endpoint (http/https)
      MushcalcWeb.Endpoint
      # Start a worker by calling: Mushcalc.Worker.start_link(arg)
      # {Mushcalc.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mushcalc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MushcalcWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

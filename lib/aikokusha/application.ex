defmodule Aikokusha.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AikokushaWeb.Telemetry,
      # Start the Ecto repository
      Aikokusha.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Aikokusha.PubSub},
      # Start Finch
      {Finch, name: Aikokusha.Finch},
      # Start the Endpoint (http/https)
      AikokushaWeb.Endpoint
      # Start a worker by calling: Aikokusha.Worker.start_link(arg)
      # {Aikokusha.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aikokusha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AikokushaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

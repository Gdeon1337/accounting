defmodule Accounting.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      %{
        id: Accounting.RedisSupervisor,
        start: {Accounting.RedisSupervisor, :start_link, [Application.get_env(:accounting, :redis_connection)]}
      },
      AccountingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Accounting.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AccountingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

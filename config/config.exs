# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :accounting, AccountingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "a/OxUbit4FwRpJo54TldQ2oj2CDOhoy+eroVwN0Eao70YkpzR43rs9cDd73cED1u",
  render_errors: [view: AccountingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Accounting.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :accounting,
  redis_connection: System.get_env("REDIS_CONNECTION"),
  pool_size: 5

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

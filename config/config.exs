# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sea_quail,
  ecto_repos: [SeaQuail.Repo]

# Configures the endpoint
config :sea_quail, SeaQuailWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qM9Xm8owehlcsBCcevHgbpFgdbq96ep73x+hVzs0bii7ft0FxK9NaJBpMKjhjzOB",
  render_errors: [view: SeaQuailWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SeaQuail.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

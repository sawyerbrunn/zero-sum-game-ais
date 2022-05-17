import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :live_test, LiveTestWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gBei1WdrwlLXoww7RBE8i0FGCe9qlXabW0qTC7NY+7r4RrZmayKVZfPVux/Ut1Ds",
  server: false

# In test we don't send emails.
config :live_test, LiveTest.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

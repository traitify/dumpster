use Mix.Config

config :logger, :custom_formatter,
  facility: :user,
  transport: :tcp,
  protocol: :rfc5424,
  app_name: "app_name",
  formatter: {Dumpster.TestFormatter, :format},
  host: {127, 0, 0, 1},
  port: 514,
  # gen_tcp and gen_udp specific
  transport_options: [],
  # timeout val is milliseconds
  timeout: 5_000,
  # unix socket path for :local transport
  path: "/dev/log"

config :logger, backends: [:console, {Dumpster, :custom_formatter}]

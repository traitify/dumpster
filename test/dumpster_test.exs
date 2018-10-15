defmodule DumpsterTest do
  use ExUnit.Case
  require Logger

  test "can configure logger with a {mod, func} formatter" do
    env = [
      facility: :user,
      transport: :tcp,
      protocol: :rfc5424,
      formatter: {Dumpster.TestFormatter, :format},
      app_name: "app_name",
      host: {127, 0, 0, 1},
      port: 514,
      # gen_tcp and gen_udp specific
      transport_options: [],
      # timeout val is milliseconds
      timeout: 5_000,
      # unix socket path for :local transport
      path: "/dev/log"
    ]

    Application.put_env(:logger, :custom_formatter, env)
    Application.put_env(:logger, :backends, [:console, {Dumpster, :custom_formatter}])

    {:ok, _} = start_supervised({Dumpster.Testing.MsgBroker, [test_pid: self()]})

    Logger.error("what up")
    assert_receive(:test_formatter_success, 1_000)
  end
end

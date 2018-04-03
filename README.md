# Dumpster

An Elixir.Logger backend for sending your logs to a syslog server via TCP, UDP,
or UNIX socket. Uses :syslog_socket under the hood.


## Why?

ExSyslogger is the only other maintained syslog backend I could find, but
unfortunately the Erlang library it wraps (:erlang-syslog) does not support TCP
or UDP transport. This is a problem if you're running Elixir in containers and
trying to use a host syslog server.

## Why did you name it 'Dumpster'?

I refer to most code (most especially my own) as a dumpster fire. Also, the
previous "log sink" (hack) I used was redirecting :console to a file, *then* having a process
reading that file and pushing the contents to rsyslog (throw in `logrotate`
and out of disk errors for a great time). If you can imagine dumping 10,000 gallons of water
in a kitchen sink vs a giant dumpster, where the sink is the previous solution
and the--oh whatever naming things is hard.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `dumpster` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dumpster, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/dumpster](https://hexdocs.pm/dumpster).


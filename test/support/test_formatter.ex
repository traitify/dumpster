defmodule Dumpster.TestFormatter do
  @moduledoc false

  def format(_level, _message, _timestamp, _metadata) do
    send(Dumpster.Testing.MsgBroker, :test_formatter_success)
    "TestFormatter success"
  end
end

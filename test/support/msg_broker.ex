defmodule Dumpster.Testing.MsgBroker do
  @moduledoc false
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(test_pid: test_pid) do
    {:ok, %{test_pid: test_pid}}
  end

  @impl GenServer
  def handle_info(:test_formatter_success, %{test_pid: test_pid} = state) do
    send(test_pid, :test_formatter_success)
    {:noreply, state}
  end
end

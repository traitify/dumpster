defmodule Dumpster do
  @moduledoc """
  Documentation for Dumpster.
  """

  @behaviour :gen_event

  @default_pattern "$date $time [$level] $levelpad$node $metadata $message\n"

  def init({__MODULE__, name}) do
    config = get_config(name, [])

    {:ok, slogger} = :syslog_socket.start_link(config[:syslog_socket_opts])
    {:ok, %{name: name, slogger: slogger, config: config}}
  end

  def handle_call({:configure, options}, %{name: name, slogger: slogger, config: _config} = state) do
    new_config = get_config(name, options)
    :syslog_socket.stop_link(slogger)
    {:ok, s} = :syslog_socket.start_link(new_config.syslog_socket_opts)
    new_state = %{state | slogger: s, config: new_config}
    {:ok, :ok, new_state}
  end

  def handle_event({_level, gl, {Logger, _, _, _}}, state)
      when node(gl) != node() do
    {:ok, state}
  end

  def handle_event(
        {level, _gl, {Logger, msg, timestamp, metatdata}},
        %{slogger: slogger, config: config} = s
      ) do
    min_level = config.level |> to_atom()

    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      event = format_event(level, msg, timestamp, metatdata, config)
      :ok = :syslog_socket.send(slogger, level, event)
    end

    {:ok, s}
  end

  def handle_event(:flush, state), do: {:ok, state}

  def handle_info(_msg, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def code_change(_old, state, _extra) do
    {:ok, state}
  end

  #### Internal functions ####

  defp to_atom(v) do
    case v do
      x when is_atom(x) -> x
      x when is_binary(x) -> String.to_atom(x)
      _ -> raise "#{inspect(v)} is not a binary or an atom"
    end
  end

  defp format_event(level, msg, timestamp, metadata, %{
         format: format,
         formatter: {Logger.Formatter, :format},
         metadata: config_metadata
       }) do
    metadata = metadata |> Keyword.take(config_metadata)

    format
    |> Logger.Formatter.format(level, msg, timestamp, metadata)
    |> to_string()
  end

  defp format_event(level, msg, timestamp, metadata, %{
         formatter: {fmt_mod, fmt_fun},
         metadata: config_metadata
       }) do
    metadata = metadata |> Keyword.take(config_metadata)
    apply(fmt_mod, fmt_fun, [level, msg, timestamp, metadata])
  end

  defp get_config(config_name, overrides) do
    env = Application.get_env(:logger, config_name, [])
    config = Keyword.merge(env, overrides)

    level = Keyword.get(config, :level, :info)
    metadata = Keyword.get(config, :metadata, [])

    formatter = Keyword.get(config, :formatter, {Logger.Formatter, :format})
    format_str = Keyword.get(config, :format, @default_pattern)
    format = Logger.Formatter.compile(format_str)

    %{
      level: level,
      format: format,
      formatter: formatter,
      metadata: metadata,
      syslog_socket_opts: get_syslog_opts(config)
    }
  end

  defp get_syslog_opts(config) do
    facility = Keyword.get(config, :facility, :local7)
    transport = Keyword.get(config, :transport, :udp)
    protocol = Keyword.get(config, :protocol, :rfc3164)
    app_name = Keyword.get(config, :app_name)
    host = Keyword.get(config, :host, {127, 0, 0, 1})
    port = Keyword.get(config, :port, 514)
    timeout = Keyword.get(config, :timeout, 5_000)
    path = Keyword.get(config, :path, "dev/log")
    transport_options = Keyword.get(config, :transport_options)
    hostname = Keyword.get(config, :hostname)

    if app_name == nil do
      raise ArgumentError, "app_name required for :dumpster config"
    end

    c = [
      facility: facility,
      transport: transport,
      protocol: protocol,
      app_name: String.to_charlist(app_name),
      host: host,
      port: port,
      timeout: timeout,
      path: String.to_charlist(path)
    ]

    c =
      case transport_options do
        x when is_list(x) -> Keyword.put(c, :transport_options, x)
        _ -> c
      end

    case hostname do
      nil -> c
      _ -> Keyword.put(c, :hostname, String.to_charlist(hostname))
    end
  end
end

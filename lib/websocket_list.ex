defmodule WebsocketTest.Client do
  require Logger

  alias Poison, as: JSON

  @behaviour :websocket_client_handler

  def start_link(sender, url, headers \\ []) do
    :crypto.start
    :ssl.start
    :websocket_client.start_link(String.to_char_list(url), __MODULE__, [sender],
                                 extra_headers: headers)
  end

  def init([sender], _conn_state) do
    {:ok, %{sender: sender, ref: 0}}
  end

  ## テキスト形式のメッセージは全てをここを経由する
  ## state.sender(自身)にメッセージを転送している
  def websocket_handle({:text, msg}, _conn_state, state) do
    GenServer.cast(state.sender, {:receive, JSON.decode!(msg)})
    {:ok, state}
  end

  def websocket_info({:send, msg}, _conn_state, state) do
    msg = Map.put(msg, :ref, to_string(state.ref + 1))
    {:reply, {:text, json!(msg)}, put_in(state, [:ref], state.ref + 1)}
  end

  def send_event(server_pid, topic, event, msg) do
    send server_pid, {:send, %{topic: topic, event: event, payload: msg}}
  end

  def send_heartbeat(server_pid) do
    send_event(server_pid, "phoenix", "heartbeat", %{})
  end

  def join(server_pid, topic, msg) do
    send_event(server_pid, topic, "phx_join", msg)
  end

  def websocket_info(msg, _conn_state, state) do
    Logger.info "ignoring: #{inspect msg}"
    {:ok, state}
  end

  def websocket_terminate(_msg, _conn_state, _state) do
    Logger.debug "websocket closed"
    :ok
  end

  defp json!(map), do: JSON.encode!(map)
end

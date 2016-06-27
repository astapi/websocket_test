defmodule WebsocketTest do
  use GenServer
  require Logger
  
  alias WebsocketTest.Client

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{})
    send(pid, :after_join)
    {:ok, pid}
  end

  def init(state) do
    {:ok, sock} = Client.start_link(self, "ws://localhost:4000/socket/websocket")
    state = Map.put(state, :socket, sock)
    Client.join(sock, "all", %{ auth_token: "ff764f6477af0560d19f12bd0fb3f87398f7c3c2d8ad68b7dd5c6f4ab0548474" })
    Client.join(sock, "user:user_id", %{ auth_token: "ff764f6477af0560d19f12bd0fb3f87398f7c3c2d8ad68b7dd5c6f4ab0548474" })

    :timer.send_interval(10000, :heartbeat)
    {:ok, state}
  end

  def handle_info(:heartbeat, state) do
    Client.send_heartbeat(state.socket)
    {:noreply, state}
  end

  def handle_info(:after_join, state) do
    # event_listを取得する
    params = %{ "index" => 0 }
    Client.send_event(state.socket, "user:user_id", "unsent_events", params)
    {:noreply, state}
  end

  def handle_cast({:receive, msg = %{ "event" => event }}, state) do
    case event do
      "join" ->
        Logger.info "channel joined"
      "new:msg" ->
        new_msg(msg, state.socket)
      "unsent_events" ->
        unsent_events(msg)
      _else ->
        Logger.info event
    end
    {:noreply, state}
  end

  def new_msg(%{"payload" => payload} = msg, socket) do
  #    Logger.info Poison.encode!(payload)
  #    message = %{"message" => "おらおら", "key" => "hogehoge"}
  #    Client.send_event(socket, "rooms:lobby", "send_message", message) 
  end

  def unsent_events(msg) do
    Logger.info Poison.encode!(msg)
  end
end

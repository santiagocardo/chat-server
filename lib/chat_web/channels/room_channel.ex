defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel

  def join("rooms:" <> room_id, _payload, socket) do
    {:ok, assign(socket, :room_id, String.to_integer(room_id))}
  end

  def handle_in("new_chat", payload, socket) do
    broadcast!(socket, "new_chat", %{
      body: payload["body"]
    })

    {:replay, :ok, socket}
  end
end

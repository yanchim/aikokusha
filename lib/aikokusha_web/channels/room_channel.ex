defmodule AikokushaWeb.RoomChannel do
  use AikokushaWeb, :channel

  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("room:" <> _private_room_id, _payload, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  @impl true
  def handle_info(:after_join, socket) do
    Aikokusha.Message.get_messages()
    # Reverse to display the latest message at the bottom of the page.
    |> Enum.reverse()
    |> Enum.each(fn msg ->
      push(socket, "shout", %{
        name: msg.name,
        message: msg.message,
        inserted_at: msg.inserted_at
      })
    end)

    # :noreply
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client.
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    Aikokusha.Message.changeset(%Aikokusha.Message{}, payload) |> Aikokusha.Repo.insert()
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end

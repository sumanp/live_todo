defmodule LiveTodoWeb.PageLive do
  use LiveTodoWeb, :live_view
  @topic "live"

  alias LiveTodo.Item

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: LiveTodoWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, items: Item.list_items())} # add items to assigns
  end

  @impl true
  def handle_event("create", %{"text" => text}, socket) do
    Item.create_item(%{text: text})
    socket = assign(socket, items: Item.list_items(), active: %Item{})
    LiveTodoWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    status = if Map.has_key?(data, "value"), do: 1, else: 0
    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{id: item.id, status: status})
    socket = assign(socket, items: Item.list_items(), active: %Item{})
    LiveTodoWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", data, socket) do
    Item.delete_item(Map.get(data, "id"))
    socket = assign(socket, items: Item.list_items(), active: %Item{})
    LiveTodoWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "update", payload: %{items: items}}, socket) do
    {:noreply, assign(socket, items: items)}
  end

  def checked?(item) do
    is_nil(item.status) and item.status > 0
  end

  def completed?(item) do
    if not is_nil(item.status) and item.status > 0, do: "completed", else: ""
  end
end

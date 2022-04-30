defmodule LiveTodoWeb.PageLive do
  use LiveTodoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

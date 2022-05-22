defmodule LiveTest.LiveHelpers do
  use LiveTestWeb, :view

  def navbar_component(socket) do
    assigns = socket.assigns
    ~L"""
    <div class="hidden md:block">
      <div class="ml-10 flex items-baseline space-x-4">
        <!-- Current: "bg-gray-900 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white" -->
        <%= link "Chess", to: Routes.live_path(socket, LiveTestWeb.ChessLive), class: "bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium" %>

        <a href="#" class="text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">Tic-Tac-Toe</a>
        <%= link "Tic-Tac-Toe", to: Routes.game_path(socket, :index), class: "text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium" %>

        <a href="#" class="text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">Bug Report</a>

        <a href="#" class="text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">About Me</a>
      </div>
    </div>
  """
  end
end

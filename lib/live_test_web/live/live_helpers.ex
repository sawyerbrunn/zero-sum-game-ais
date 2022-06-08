defmodule LiveTest.LiveHelpers do
  use LiveTestWeb, :view

  def navbar_component(socket) do
    assigns = socket.assigns
    ~L"""
    <div class="hidden md:block">
      <div class="ml-10 flex items-baseline space-x-4">
        <!-- Current: "bg-gray-900 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white" -->
        <%= link "Chess", to: Routes.live_path(socket, LiveTestWeb.ChessLive), class: get_chess_link_class(socket) %>

        <%= #link "Tic-Tac-Toe (Beta)", to: Routes.game_path(socket, :index), class: get_ttt_link_class(socket) %>

        <a href="#" class="text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">Bug Report</a>

        <a href="#" class="text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">About Me</a>
      </div>
    </div>
  """
  end

  defp get_chess_link_class(%{view: LiveTestWeb.ChessLive} = _socket), do: "bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium"
  defp get_chess_link_class(_socket), do: "text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
  # defp get_ttt_link_class(%{view: LiveTestWeb.GameLive} = _socket), do: "bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium"
  # defp get_ttt_link_class(_socket), do: "text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
end

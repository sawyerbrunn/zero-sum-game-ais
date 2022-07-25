defmodule LiveTest.LiveHelpers do
  use LiveTestWeb, :view

  def navbar_component(socket) do
    assigns = socket.assigns
    ~L"""
    <ul class="navbar-nav flex flex-col pl-0 list-style-none mr-auto">
      <li class="nav-item p-2">
        <%= link "Chess", to: Routes.live_path(socket, LiveTestWeb.ChessLive), class: get_chess_link_class(socket) %>
      </li>
      <li class="nav-item p-2">
        <%= link "Tic-Tac-Toe (Beta)", to: Routes.tic_tac_toe_path(socket, :index), class: get_ttt_link_class(socket) %>
      </li>
      <li class="nav-item p-2">
        <a
          class="nav-link text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
          href="https://github.com/sawyerbrunn/zero-sum-game-ais"
          target="_blank"
          >Source Code</a>
      </li>
      <li class="nav-item p-2">
        <a
          class="nav-link text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
          href="https://github.com/sawyerbrunn/zero-sum-game-ais/issues"
          target="_blank"
          >Bug Report</a>
      </li>
    </ul>
    """
  end

  defp get_chess_link_class(%{view: LiveTestWeb.ChessLive} = _socket), do: "nav-link bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium"
  defp get_chess_link_class(_socket), do: "nav-link text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
  defp get_ttt_link_class(%{view: LiveTestWeb.TicTacToeLive} = _socket), do: "nav-link bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium"
  defp get_ttt_link_class(_socket), do: "nav-link text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
end

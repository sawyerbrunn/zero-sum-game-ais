defmodule LiveTestWeb.ChessLive do
  use LiveTestWeb, :live_view
  require Logger

  @defaults [modal: nil, winner: nil, game_over_reason: nil]

  @impl true
  def mount(_params, _session, socket) do

    {:ok, assign(socket, @defaults)}
  end

  @impl true
  def handle_event("game-over", %{"winner" => winner, "gameOverReason" => reason}, socket) do
    {:noreply,
      socket
      |> assign(modal: "chess-modal")
      |> assign(winner: winner_str(winner))
      |> assign(game_over_reason: reason)
    }
  end

  def handle_event("close-modal", _, socket) do
    {:noreply, assign(socket, :modal, nil)}
  end

  def handle_event(message, params, socket) do
    Logger.error("Failed to handle an event correctly")
    IO.inspect(message)
    IO.inspect(params)
    {:noreply, socket}
  end


  defp winner_str("b"), do: "Black"

  defp winner_str("w"), do: "White"
end

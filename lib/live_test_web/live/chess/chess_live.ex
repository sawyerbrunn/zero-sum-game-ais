defmodule LiveTestWeb.ChessLive do
  use LiveTestWeb, :live_view
  require Logger

  alias LiveTest.Chess.AILevelZero
  alias LiveTest.Chess.AIWebApi

  @defaults [modal: nil, winner: nil, game_over_reason: nil, history: []]

  @impl true
  def mount(_params, _session, socket) do

    {:ok, assign(socket, @defaults)}
  end

  @impl true
  # def handle_event("game-over", %{"winner" => winner, "gameOverReason" => reason}, socket) do
  #   {:noreply,
  #     socket
  #     |> assign(modal: "chess-modal")
  #     |> assign(winner: winner_str(winner))
  #     |> assign(game_over_reason: reason)
  #     |> push_event("refresh-board", %{test: ""})
  #   }
  # end

  def handle_event("game-over", %{"status" => status}, socket) do
    {:noreply,
      socket
      |> assign(modal: "chess-modal")
      |> assign(game_over_status: status)
      |> push_event("refresh-board", %{test: ""})
    }
  end

  def handle_event("update-history", %{"history" => history}, socket) do
    {:noreply,
      socket
      |> assign(history: history)
    }
  end

  def handle_event("close-modal", _, socket) do
    {:noreply,
      socket
      |> assign(:modal, nil)
      |> push_event("refresh-board", %{})
    }
  end

  def handle_event("set-fen", _, socket) do
    # fen = "r4Q2/pbpk3p/1p5P/n2P4/4Q3/8/PPP1P3/RNB1KBNR w KQ - 1 19"
    fen2 = "rnb1k2r/pppp1ppp/5n2/2b5/7q/2P5/P5PN/1q1B1K1R w kq - 0 14"
    {:noreply, push_event(socket, "set-fen", %{fen: fen2})}
  end

  def handle_event("request-move", %{"fen" => game_fen, "turn" => turn} = _params, socket) do
    move = AILevelZero.find_move(game_fen, turn)
    :timer.sleep(250)
    # move = AIWebApi.find_move(game_fen, turn)
    {:noreply,
      socket
      |> push_event("receive-move", %{source: move.source, target: move.target, displayName: move.display_name})
   }
  end

  def handle_event(message, params, socket) do
    Logger.error("Failed to handle an event correctly")
    IO.inspect(message)
    IO.inspect(params)
    {:noreply, socket}
  end


  defp winner_str("b"), do: "Black"

  defp winner_str("w"), do: "White"

  # Components
  defp game_history_component(assigns) do
    history = assigns.history
    moves = Enum.chunk_every(history, 2)
    ~H"""
    <%= for {move_seq, i} <- Enum.with_index(moves) do %>
      <div>
        <% white_move = Enum.at(move_seq, 0) %>
        <% black_move = Enum.at(move_seq, 1) || "" %>
        <%= "#{i + 1}. #{white_move} #{black_move}" %>
      </div>
    <% end %>
    """
  end
end

defmodule LiveTestWeb.ChessLive do
  use LiveTestWeb, :live_view
  require Logger

  alias LiveTest.Chess.AILevelZero
  alias LiveTest.Chess.Player
  # alias LiveTest.Chess.AIWebApi

  @defaults [modal: nil, winner: nil, game_over_reason: nil, history: [], playing_ai_battle: false]

  @impl true
  def mount(_params, _session, socket) do

    {:ok,
      assign(socket, @defaults)
      |> assign(white_player: %Player{type: :manual})
      |> assign(black_player: %Player{type: :ai_minimax})
    }
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
    # some checkmate test fens
    # fen = "r4Q2/pbpk3p/1p5P/n2P4/4Q3/8/PPP1P3/RNB1KBNR w KQ - 1 19"
    # fen2 = "rnb1k2r/pppp1ppp/5n2/2b5/7q/2P5/P5PN/1q1B1K1R w kq - 0 14"
    # fen3 = "6k1/1p6/p7/8/5b1K/3b1q2/3rrn2/4q1q1 b - - 11 91"

    # this fen causes an AI crash issue:
    fen4 = "3Q1Q2/8/4k3/p7/P7/1P1P4/8/1K6 b - - 0 60"
    {:noreply, push_event(socket, "set-fen", %{fen: fen4})}
  end

  def handle_event("request-move", %{"fen" => game_fen, "turn" => turn} = _params, socket) do
    move = AILevelZero.find_move(game_fen, turn)
    # move = AIWebApi.find_move(game_fen, turn)
    {:noreply,
      socket
      |> push_event("receive-move", %{source: move.source, target: move.target, displayName: move.display_name})
   }
  end

  def handle_event("white-player-settings-updated", %{"white_player_settings" => settings} = _params, socket) do
    type = settings["player_type"]
    depth = settings["depth"] || Player.default_depth()
    new_white_player = %Player{type: String.to_existing_atom(type), depth: depth}
    {:noreply,
      socket
      |> assign(white_player: new_white_player)
      |> push_event("update-white-player-settings", %{type: type, depth: depth})
    }

  end

  def handle_event("black-player-settings-updated", %{"black_player_settings" => settings} = _params, socket) do
    type = settings["player_type"]
    depth = settings["depth"] || Player.default_depth()
    new_black_player = %Player{type: String.to_existing_atom(type), depth: depth}
    {:noreply,
      socket
      |> assign(black_player: new_black_player)
      |> push_event("update-black-player-settings", %{type: type, depth: depth})
    }
  end

  def handle_event("toggle-ai-battle", _, socket) do
    {:noreply,
      socket
      |> assign(playing_ai_battle: !socket.assigns.playing_ai_battle)
      |> push_event("toggle-ai-battle", %{})
    }
  end

  def handle_event("pause-ai-game", _, socket) do
    {:noreply, assign(socket, playing_ai_battle: false)}
  end

  def handle_event(message, params, socket) do
    Logger.error("Failed to handle an event correctly")
    IO.inspect(message)
    IO.inspect(params)
    {:noreply, socket}
  end


  # defp winner_str("b"), do: "Black"

  # defp winner_str("w"), do: "White"

  # for building
  # @history ["a1", "a2", "a3", "a4", "a1", "a2", "a3", "a4", "a1", "a2", "a3", "a4", "a1", "a2", "a3", "a4", "a1", "a2", "a3", "a4"]

  # Components
  defp game_history_component(assigns) do
    history = assigns.history
    moves = Enum.chunk_every(history, 2)
    ~H"""
    <div class="border border-gray-800 shadow rounded-md bg-zinc-100">
      <div class="text-center text-extrabold text-xl border-b border-gray-500 bg-zinc-400">
        <span> Game History </span>
      </div>
      <div class="grid gird-cols-3 px-4 py-1">
        <div class="font-semibold text-xl col-start-1 col-span-1">
          <span>Turn</span>
        </div>
        <div class="font-semibold text-xl col-start-2 col-span-1">
          <span> White </span>
        </div>
        <div class="font-semibold text-xl col-start-3 col-span-1">
          <span> Black </span>
        </div>
      </div>
      <div class=" h-80 overflow-y-auto">
        <%= for {move_seq, i} <- Enum.with_index(moves) do %>
          <div class={"px-4 py-1 grid grid-cols-3" <> if rem(i, 2) == 0, do: " bg-zinc-200", else: " bg-zinc-300"}>
            <% white_move = Enum.at(move_seq, 0) %>
            <% black_move = Enum.at(move_seq, 1) || "" %>
            <div class="font-semibold text-xl col-start-1 col-span-1">
              <%= "#{i + 1}." %>
            </div>
            <div class="text-xl px-2 col-start-2 col-span-1">
              <%= white_move %>
            </div>
            <div class="text-xl px-2 col-start-3 col-span-1">
              <%= black_move %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end

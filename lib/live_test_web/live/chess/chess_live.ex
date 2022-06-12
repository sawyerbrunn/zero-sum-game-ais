defmodule LiveTestWeb.ChessLive do
  use LiveTestWeb, :live_view
  require Logger

  alias LiveTest.Chess.AILevelZero
  alias LiveTest.Chess.Player
  # alias LiveTest.Chess.AIWebApi

  @defaults [modal: nil, winner: nil, game_over_reason: nil, history: [], playing_ai_battle: false, wso: false, bso: false, score: 0]

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
    # fen = "rnb1k2r/pppp1ppp/5n2/2b5/7q/2P5/P5PN/1q1B1K1R w kq - 0 14"
    # fen = "6k1/1p6/p7/8/5b1K/3b1q2/3rrn2/4q1q1 b - - 11 91"

    # this fen causes an AI crash issue:
    # fen = "3Q1Q2/8/4k3/p7/P7/1P1P4/8/1K6 b - - 0 60"

    # This fen is causing null moves returned from minimax:
    # fen = "4Q1Q1/3R4/8/8/4k3/8/7P/6K1 b - - 1 56"
    # fen = "r1b2bnr/pp2pkpp/8/q7/5B2/2N5/PP3PPP/n4RK1 w - - 0 11"
    # fen = "2r5/pk6/3Qp3/2Bp4/3P2P1/P3P2P/4KP2/6q1 w - - 3 32"
    # fen = "1Q2R3/p1k2ppp/2p3b1/2n1p1P1/3qP3/2NP1P2/P6P/2B1K2R b K - 4 25" # global score 1122
    # fen = "8/1R4k1/7p/8/3PK1P1/P6P/1P6/8 b - - 2 61"
    # fen = "2k3rr/p1pp4/1p4qp/n3p3/2b1Pp1P/5B2/PP6/R1B1RK2 w - - 0 28"
    fen = "3rkb1r/ppR3pp/4P3/8/N4Q2/PP1p2B1/6PP/3K1Bq1 b k - 0 24"
    {:noreply, push_event(socket, "set-fen", %{fen: fen})}
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
      |> assign(wso: true)
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
      |> assign(bso: true)
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

  def handle_event("update-score", %{"score" => score}, socket) do
    {:noreply,
      assign(socket, score: score)
    }
  end

  def handle_event("pause-ai-game", _, socket) do
    {:noreply, assign(socket, playing_ai_battle: false)}
  end

  def handle_event("change-wso", _, socket) do
    {:noreply, assign(socket, wso: !socket.assigns.wso)}
  end

  def handle_event("change-bso", _, socket) do
    {:noreply, assign(socket, bso: !socket.assigns.bso)}
  end

  def handle_event(message, params, socket) do
    Logger.error("Failed to handle an event correctly")
    IO.inspect(message)
    IO.inspect(params)
    {:noreply, socket}
  end

  ### COMPONENTS ###

  defp game_score_component(assigns) do
    ~H"""
    <div class="flex justify-left">
      <label> Status: </label>
      <div class="pl-1" id="status" phx-update="ignore" />
    </div>
    <div class="flex justify-left">
      <label> Score: </label>
      <div id="globalScore" phx-update="ignore" class="px-1" />
    </div>
    """
  end

  defp game_ai_settings_component(assigns) do
    ~H"""
    <div class="grid grid-cols-3 space-x-1">
      <div class="col-start-1 col-span-1">
        <button class="w-full inline-block px-6 py-2.5 bg-gray-600 text-white font-medium text-xs leading-tight uppercase rounded shadow-md hover:bg-gray-700 hover:shadow-lg focus:bg-gray-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-gray-800 active:shadow-lg transition duration-150 ease-in-out"
          phx-click="change-wso" type="button" data-bs-toggle="collapse" data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
          White AI
        </button>
      </div>
      <div class="col-start-2 col-span-1">
        <button id="aiBtn" phx-click="toggle-ai-battle" class={"w-full inline-block px-6 py-2.5 bg-gray-600 text-white font-medium text-xs leading-tight uppercase rounded shadow-md hover:bg-gray-700 hover:shadow-lg focus:bg-gray-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-gray-800 active:shadow-lg transition duration-150 ease-in-out" <> if @white_player.type != :manual and @black_player.type != :manual, do: "", else: " hidden"}>
          <%= if !@playing_ai_battle, do: "AI vs AI", else: "Pause" %>
        </button>
      </div>
      <div class="col-start-3 col-span-1">
        <button class="w-full inline-block px-6 py-2.5 bg-gray-600 text-white font-medium text-xs leading-tight uppercase rounded shadow-md hover:bg-gray-700 hover:shadow-lg focus:bg-gray-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-gray-800 active:shadow-lg transition duration-150 ease-in-out"
        phx-click="change-bso" type="button" data-bs-toggle="collapse" data-bs-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
            Black AI
        </button>
      </div>
    </div>
    <div phx-update="ignore">
      <div id="collapseOne" class={"accordion-collapse collapse" <> if @wso, do: " show", else: ""} aria-labelledby="headingOne"
        data-bs-parent="#accordionExample">
        <div class="accordion-body py-2 px-5">
          <div>
            <%= form_for :white_player_settings, "#", [phx_change: "white-player-settings-updated"], fn f -> %>
              <div class="grid grid-cols-2 space-x-2">
                <div class="col-start-1 col-span-1">
                  <label>White Player Type</label>
                  <%= select f, :player_type, [{"Manual", :manual}, {"Random AI", :ai_random}, {"Minimax AI", :ai_minimax}], selected: @white_player.type,
                    class: "form-select appearance-none
                      block
                      w-full
                      px-3
                      py-1.5
                      text-base
                      font-normal
                      text-gray-700
                      bg-white bg-clip-padding bg-no-repeat
                      border border-solid border-gray-300
                      rounded
                      transition
                      ease-in-out
                      m-0
                      focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none" %>
                </div>
                <div>
                  <label> Minimax Depth </label>
                  <%= select f, :depth, [1, 2, 3, 4, 5], selected: @white_player.depth,
                    class: "form-select appearance-none
                      block
                      w-full
                      px-3
                      py-1.5
                      text-base
                      font-normal
                      text-gray-700
                      bg-white bg-clip-padding bg-no-repeat
                      border border-solid border-gray-300
                      rounded
                      transition
                      ease-in-out
                      m-0
                      focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none" %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    <div phx-update="ignore">
      <div id="collapseTwo" class={"accordion-collapse collapse" <> if @bso, do: " show", else: ""} aria-labelledby="headingTwo"
        data-bs-parent="#accordionExample">
        <div class="accordion-body py-2 px-5">
          <div>
            <%= form_for :black_player_settings, "#", [phx_change: "black-player-settings-updated"], fn f -> %>
              <div class="grid grid-cols-2 space-x-2">
                <div class="col-start-1 col-span-1">
                  <label>Black Player Type</label>
                  <%= select f, :player_type, [{"Manual", :manual}, {"Random AI", :ai_random}, {"Minimax AI", :ai_minimax}], selected: @black_player.type,
                  class: "form-select appearance-none
                    block
                    w-full
                    px-3
                    py-1.5
                    text-base
                    font-normal
                    text-gray-700
                    bg-white bg-clip-padding bg-no-repeat
                    border border-solid border-gray-300
                    rounded
                    transition
                    ease-in-out
                    m-0
                    focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none" %>
                </div>
                <div class="col-start-2 col-span-1">
                  <label> Minimax Depth</label>
                  <%= select f, :depth, [1, 2, 3, 4, 5], selected: @black_player.depth,
                    class: "form-select appearance-none
                    block
                    w-full
                    px-3
                    py-1.5
                    text-base
                    font-normal
                    text-gray-700
                    bg-white bg-clip-padding bg-no-repeat
                    border border-solid border-gray-300
                    rounded
                    transition
                    ease-in-out
                    m-0
                    focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none" %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp game_buttons_component(assigns) do
    ~H"""
    <div class="grid grid-cols-4 space-x-2">
      <div class="col-start-1 col-span-1">
        <button data-bs-toggle="modal" data-bs-target="#newGameModal" class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 border border-gray-700 rounded w-full">
          New
        </button>
      </div>
      <div class="col-start-2 col-span-1">
        <button id="undoBtn" phx-click="pause-ai-game" class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 border border-gray-700 rounded w-full">
          Undo
        </button>
      </div>
      <div class="col-start-3 col-span-1">
        <button id="flipBoardBtn" class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 border border-gray-700 rounded w-full">
          Flip
        </button>
      </div>
      <div class="col-start-4 col-span-1">
        <button data-bs-toggle="modal" data-bs-target="#fenModal" class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 border border-gray-700 rounded w-full">
          Fen
        </button>
      </div>
    </div>
    """
  end

  defp game_history_component(assigns) do
    history = assigns.history
    moves = Enum.chunk_every(history, 2)
    ~H"""
    <div class="h-40 md:h-80 overflow-y-auto">

      <div class="text-center font-semibold border-b border-gray-200 underline md:text-xl">
        <h2> Game History </h2>
      </div>
      <%= if @history != [] do %>
        <div class="grid grid-cols-3">
          <div class="col-start-1 col-span-1 text-center">
            Turn
          </div>
          <div class="col-start-2 col-span-1 text-center">
            White
          </div>
          <div class="col-start-3 col-span-1 text-center">
            Black
          </div>
        </div>

        <div>
          <%= for {move_seq, i} <- Enum.with_index(moves) do %>
            <div class={"px-4 py-1 grid grid-cols-3" <> if rem(i, 2) == 0, do: " bg-zinc-200", else: " bg-zinc-300"}>
              <% white_move = Enum.at(move_seq, 0) %>
              <% black_move = Enum.at(move_seq, 1) || "" %>
              <div class="font-semibold text-xl col-start-1 col-span-1 text-center">
                <%= "#{i + 1}." %>
              </div>
              <div class="text-xl px-2 col-start-2 col-span-1 text-center">
                <%= white_move %>
              </div>
              <div class="text-xl px-2 col-start-3 col-span-1 text-center">
                <%= black_move %>
              </div>
            </div>
          <% end %>

        </div>
      <% else %>
      <div class="py-8 px-10 text-center">
        <p> It's quiet... too quiet...</p>
        <p> Drag a piece to get started! </p>
      </div>
      <% end %>

    </div>
    """
  end
end

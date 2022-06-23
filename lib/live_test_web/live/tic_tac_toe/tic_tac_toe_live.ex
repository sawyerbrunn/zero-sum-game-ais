defmodule LiveTestWeb.TicTacToeLive do
  use LiveTestWeb, :live_view
  require Logger
  alias LiveTest.TicTacToe.Board
  alias LiveTest.TicTacToe.AiRandom
  alias LiveTest.TicTacToe.AiMinimax

  @ai_opts [{"Manual", :manual}, {"Random", :ai_random}, {"Minimax", :ai_minimax}]

  @impl true
  def mount(_params, _session, socket) do

    board = Board.new()

    {:ok,
      socket
      |> assign(board: board)
      |> assign(turn: board.current_turn)
      |> assign(winner: nil)
      |> assign(ai_opts: @ai_opts)
      |> assign(x_opt: :ai_minimax)
      |> assign(o_opt: :manual)
      |> assign(ai_player: "X")
      |> maybe_request_ai_move()
    }
  end

  def handle_event("move", _params, socket) when socket.assigns.winner != nil do
    {:noreply,
      socket
      # |> put_flash(:info, "The game is over! #{socket.assigns.winner} has won.")
    }
  end

  # Handle manual moves from the user
  def handle_event("move", %{"index" => index_str}, socket) do
    {index, _} = Integer.parse(index_str)
    board = socket.assigns.board
    turn = socket.assigns.turn

    cond do
      board.current_turn == "X" and socket.assigns.x_opt != :manual ->
        {:noreply, socket}
      board.current_turn == "O" and socket.assigns.o_opt != :manual ->
        {:noreply, socket}
      true ->
        case Board.make_move(board, turn, index) do
          %Board{current_turn: new_turn} = new_board ->
            {:noreply,
              socket
              |> assign(board: new_board)
              |> assign(turn: new_turn)
              |> assign(winner: Board.find_winner(new_board))
              |> maybe_request_ai_move()
            }
          error ->
            IO.inspect("illegal move attempted. Reason: #{error}")
            {:noreply, socket}
        end
    end
  end

  def handle_event("new-game", _, socket) do
    board = Board.new()

    {:noreply,
      socket
      |> assign(winner: nil)
      |> assign(board: board)
      |> assign(turn: board.current_turn)
      |> clear_flash()
      |> maybe_request_ai_move()
    }
  end

  def handle_event("undo", _, socket) do
    x_opt = socket.assigns.x_opt
    o_opt = socket.assigns.o_opt
    board = socket.assigns.board
    new_board =
      if x_opt == :manual and o_opt == :manual do
        # Undo onee if both are manual
        board
        |> Board.undo()
      else
        # Otherwise, undo twice
        board
        |> Board.undo()
        |> Board.undo()
      end
    {:noreply,
      socket
      |> assign(board: new_board)
      |> assign(turn: new_board.current_turn)
      |> assign(winner: Board.find_winner(new_board))
    }
  end

  def handle_event("ai-player-updated", %{"ai_player" => %{"ai_player" => val}}, socket) do
    {:noreply,
      socket
      |> assign(ai_player: val)
      |> assign(x_opt: other_opt(socket.assigns.x_opt))
      |> assign(o_opt: other_opt(socket.assigns.o_opt))
      |> maybe_request_ai_move()
    }
  end

  @impl true
  def handle_event(val, params, socket) do
    Logger.error("failed to handle an event")
    IO.inspect(params, label: "params")
    IO.inspect(val, label: "val")
    {:noreply, socket}
  end

  @impl true
  def handle_info(:ai_move, socket) do
    # Just makes a random move for now
    board = socket.assigns.board
    x_opt = socket.assigns.x_opt
    o_opt = socket.assigns.o_opt

    module =
      cond do
        board.current_turn == "X" and x_opt == :ai_random ->
          AiRandom
        board.current_turn == "X" and x_opt == :ai_minimax ->
          AiMinimax
        board.current_turn == "O" and o_opt == :ai_random ->
          AiRandom
        board.current_turn == "O" and o_opt == :ai_minimax ->
          AiMinimax
        true ->
          Logger.error("No matching module for #{x_opt} / #{o_opt}")
          nil
      end
    case Board.find_winner(board) do
      nil ->
        move = module.find_move(board)
        case Board.make_move(board, socket.assigns.turn, move) do
          %Board{} = new_board ->
            {:noreply,
              socket
              |> assign(board: new_board)
              |> assign(turn: new_board.current_turn)
              |> assign(winner: Board.find_winner(new_board))
            }
          _ ->
            Logger.error("AI find_move/1 returned an illegal move.")
            {:noreply, socket}
        end
      _ ->
        # The game is over.
        {:noreply, socket}
    end
  end

  defp maybe_request_ai_move(%{assigns: %{board: board, x_opt: x_opt, o_opt: o_opt}} = socket) do
    cond do
      board.current_turn == "X" and x_opt != :manual ->
        Process.send_after(self(), :ai_move, 1000)
      board.current_turn == "O" and o_opt != :manual ->
        Process.send_after(self(), :ai_move, 1000)
      true ->
        nil
    end
    socket
  end

  ### Components ###

  defp game_buttons_component(assigns) do
    ~H"""
    <div class="grid grid-cols-2 space-x-2">
      <div class="col-start-1 col-span-1">
        <button data-bs-toggle="modal" data-bs-target="#newGameModal" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 border border-blue-700 rounded w-full">
          New Game
        </button>
      </div>
      <div class="col-start-2 col-span-1">
        <button phx-click="undo" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 border border-blue-700 rounded w-full">
          Undo Move
        </button>
      </div>
    </div>
    """
  end

  defp o_component(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-20 w-20" fill="none" viewBox="0 0 24 24" stroke="blue" stroke-width="2">
      <path stroke-linecap="round" stroke-linejoin="round" d="M3 12h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
    """
  end

  defp x_component(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-20 w-20" fill="none" viewBox="0 0 24 24" stroke="red" stroke-width="2">
      <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
    </svg>
    """
  end

  defp other_opt(:manual), do: :ai_minimax
  defp other_opt(:ai_minimax), do: :manual
end

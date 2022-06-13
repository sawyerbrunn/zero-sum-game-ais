defmodule LiveTestWeb.TicTacToeLive do
  use LiveTestWeb, :live_view
  require Logger
  alias LiveTest.TicTacToe.Board

  @ai_opts [{"Manual", :manual}, {"AI Level 0", :ai_zero}]

  @impl true
  def mount(_params, _session, socket) do

    board = Board.new()

    {:ok,
      socket
      |> assign(board: board)
      |> assign(turn: board.current_turn)
      |> assign(winner: nil)
      |> assign(@ai_opts)
      |> assign(x_opt: :manual)
      |> assign(o_opt: :ai_zero)
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
            Process.send_after(self(), :ai_move, 1000)
            {:noreply,
              socket
              |> assign(board: new_board)
              |> assign(turn: new_turn)
              |> assign(winner: Board.find_winner(new_board))
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
    case Board.list_legal_moves(board) do
      [] ->
        {:noreply, socket}
      legal_moves ->
        index = Enum.random(legal_moves)

        # Assumes chosen move is legal
        new_board = Board.make_move(board, socket.assigns.turn, index)
        new_turn = new_board.current_turn
        {:noreply,
          socket
          |> assign(board: new_board)
          |> assign(turn: new_turn)
          |> assign(winner: Board.find_winner(new_board))
        }
    end
  end

  # # make a move and out the move in the socket
  # defp maybe_make_ai_move(socket) do
  #   turn = socket.assigns.turn
  #   move = make_move(:ai_zero, socket.assigns.board)
  #   board = Map.put(socket.assigns.board, move, turn)
  #   socket
  #   |> assign(board: board)
  #   |> assign(turn: other(turn))
  #   |> assign(winner: find_winner(board))
  # end

  # defp make_move(:ai_zero, board) do
  #   0..8
  #   |> Enum.to_list()
  #   |> Enum.filter(&is_legal?(board, &1))
  #   |> Enum.random()
  # end

  # defp is_legal?(board, i) do
  #   Map.get(board, i) == "_"
  # end

  # defp find_winner(board) do
  #   checks = [
  #     [0, 1, 2],
  #     [3, 4, 5],
  #     [6, 7, 8],
  #     [0, 3, 6],
  #     [1, 4, 7],
  #     [2, 5, 8],
  #     [0, 4, 8],
  #     [2, 4, 6]
  #   ]
  #   Enum.map(checks, fn check_list ->
  #     if Map.get(board, Enum.at(check_list, 0)) != "_" and Map.get(board, Enum.at(check_list, 0)) == Map.get(board, Enum.at(check_list, 1)) and Map.get(board, Enum.at(check_list, 0)) ==Map.get(board, Enum.at(check_list, 2)) do
  #       Map.get(board, Enum.at(check_list, 0))
  #     else
  #       nil
  #     end
  #   end)
  #   |> Enum.filter(& &1 != nil)
  #   |> case do
  #     [] -> nil
  #     _ = winner_list -> Enum.at(winner_list, 0)
  #   end
  # end

  # defp other("X"), do: "O"
  # defp other("O"), do: "X"

  ### Components ###

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
end

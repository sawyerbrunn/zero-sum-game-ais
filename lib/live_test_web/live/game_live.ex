defmodule LiveTestWeb.GameLive do
  use LiveTestWeb, :live_view

  @ai_opts [{"Manual", :manual}, {"AI Level 0", :ai_zero}]


  @impl true
  def mount(_params, _session, socket) do

    turn = "X"
    board =
      0..8
      |> Map.new(& {&1, "_"})

    {:ok,
      socket
      |> assign(turn: turn)
      |> assign(board: board)
      |> assign(winner: nil)
      |> assign(@ai_opts)
      |> assign(x_opt: :manual)
      |> assign(o_opt: :ai_zero)
    }
  end

  def handle_event("move", _params, socket) when socket.assigns.winner != nil do
    {:noreply,
      socket
      |> put_flash(:info, "The game is over! #{socket.assigns.winner} has won.")
    }
  end

  def handle_event("move", %{"index" => index_str}, socket) do
    {index, _} = Integer.parse(index_str)

    current_board = socket.assigns.board
    if Map.get(current_board, index) != "_" do
      {:noreply,
        socket
        |> put_flash(:info, "Please choose a non-empty square!")}
    else
      board =
        current_board
        |> Map.put(index, socket.assigns.turn)

      winner = find_winner(board)
      new_turn = other(socket.assigns.turn)
      {:noreply,
        socket
        |> assign(board: board)
        |> assign(turn: new_turn)
        |> assign(winner: winner)
        |> clear_flash()
        |> maybe_make_ai_move()
      }
    end
  end

  def handle_event("new-game", _, socket) do
    board =
      0..8
      |> Map.new(& {&1, "_"})

    {:noreply,
      socket
      |> assign(winner: nil)
      |> assign(board: board)
      |> assign(turn: "X")
      |> clear_flash()
    }
  end

  @impl true
  def handle_event(val, params, socket) do
    IO.inspect("failed to handle an event")
    IO.inspect(params, label: "params")
    IO.inspect(val, label: "val")
    {:noreply, socket}
  end

  # make a move and out the move in the socket
  defp maybe_make_ai_move(socket) do
    turn = socket.assigns.turn
    move = make_move(:ai_zero, socket.assigns.board)
    board = Map.put(socket.assigns.board, move, turn)
    socket
    |> assign(board: board)
    |> assign(turn: other(turn))
    |> assign(winner: find_winner(board))
  end

  defp make_move(:ai_zero, board) do
    0..8
    |> Enum.to_list()
    |> Enum.filter(&is_legal?(board, &1))
    |> Enum.random()
  end

  defp is_legal?(board, i) do
    Map.get(board, i) == "_"
  end

  defp find_winner(board) do
    checks = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ]
    Enum.map(checks, fn check_list ->
      if Map.get(board, Enum.at(check_list, 0)) != "_" and Map.get(board, Enum.at(check_list, 0)) == Map.get(board, Enum.at(check_list, 1)) and Map.get(board, Enum.at(check_list, 0)) ==Map.get(board, Enum.at(check_list, 2)) do
        Map.get(board, Enum.at(check_list, 0))
      else
        nil
      end
    end)
    |> Enum.filter(& &1 != nil)
    |> case do
      [] -> nil
      _ = winner_list -> Enum.at(winner_list, 0)
    end
  end

  defp other("X"), do: "O"
  defp other("O"), do: "X"
end

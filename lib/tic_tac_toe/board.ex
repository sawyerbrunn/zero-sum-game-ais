defmodule LiveTest.TicTacToe.Board do
  @moduledoc """
  A simple representation of a Tic Tac Toe board.

  A board has a state, a current turn, and a history.
  """

  @initial_state Enum.map(0..8, & {&1, nil}) |> Map.new()
  @pieces ["X", "O"]

  defstruct [
    state: @initial_state,
    current_turn: "X",
    turn_number: 0,
    history: %{}
  ]

  @doc """
  Creates a fresh tic tac toe board, initialized
  to the empty state.
  """
  def new() do
    %__MODULE__{}
  end

  @doc """
  Attempts to place the given piece at the given
  index on the board.

  Returns a new board is successful. Otherwise,
  returns an atom representing the error.
  """
  def make_move(%__MODULE__{} = board, piece, index) do
    case validate_move(board, piece, index) do
      :ok ->
        %__MODULE__{
          state: Map.put(board.state, index, piece),
          current_turn: other(board.current_turn),
          turn_number: board.turn_number + 1,
          history: Map.put(board.history, board.turn_number, board.state)
        }
      error ->
        error
    end
  end

  @doc """
  Undoes the last move make on the board, and returns
  a new board.

  Does nothing if the the board is in the initial state.
  """
  def undo(%__MODULE__{turn_number: turn_number} = board) do
    if turn_number == 0 do
      board
    else
      %__MODULE__{
        state: Map.get(board.history, turn_number - 1),
        current_turn: other(board.current_turn),
        turn_number: turn_number - 1,
        history: Map.delete(board.history, turn_number - 1)
      }
    end
  end

  @doc """
  Lists all legal moves that can be made on the
  given board.

  A move is just an index to make a move at (0..8)
  """
  def list_legal_moves(%__MODULE__{} = board) do
    0..8
    |> Enum.map(& &1)
    |> Enum.filter(& validate_move(board, board.current_turn, &1) == :ok)
  end

  def validate_move(board, piece, index) do
    cond do
      find_winner(board) != nil ->
        :game_over
      board.current_turn != piece ->
        :wrong_turn
      piece not in @pieces ->
        :invalid_piece
      Map.get(board.state, index, :bad_index) != nil ->
        :nonempty_square
      true ->
        :ok
    end
  end

  def find_winner(board) do
    state = board.state
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
      [i1, i2, i3] = check_list
      if Map.get(state, i1) != nil and Map.get(state, i1) == Map.get(state, i2) and Map.get(state, i2) == Map.get(state, i3) do
        Map.get(state, i1)
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

  ### Private ###

  defp other("X"), do: "O"
  defp other("O"), do: "X"
end

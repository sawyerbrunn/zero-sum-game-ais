defmodule LiveTest.TicTacToe.AiRandom do
  @moduledoc """
  A basic Tic Tac Toe AI that makes random moves.
  """
  @behaviour LiveTest.TicTacToe.Ai
  alias LiveTest.TicTacToe.Board
  require Logger


  def find_move(board) do
    legal_moves = Board.list_legal_moves(board)
    case legal_moves do
      [] ->
        Logger.warn("[LiveTest.TicTacToe.AiRandom] find_move/1 called with no legal moves.")
        nil
      moves ->
        Enum.random(moves)
    end
  end
end

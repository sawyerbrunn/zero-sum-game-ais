defmodule LiveTest.TicTacToe.Ai do
  @moduledoc """
  Behavior of all tic tac toe AIs
  """
  alias LiveTest.TicTacToe.Board
  @callback find_move(Board.t) :: number()
end

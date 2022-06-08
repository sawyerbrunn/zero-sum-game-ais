defmodule LiveTest.Chess.AILevelZero do

  alias LiveTest.Chess.Move


  # TODO: Implement random moves
  def find_move(_game_fen, _turn) do
    %Move{source: "a7", target: "a6", display_name: "a7a6"}
  end


end

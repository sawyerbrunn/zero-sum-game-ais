defmodule LiveTest.Chess.AILevelZero do

  alias LiveTest.Chess.Move


  # TODO: Implement random moves
  def find_move(game_fen, turn) do
    IO.inspect(game_fen);
    IO.inspect(turn);
    %Move{source: "a7", target: "a6", display_name: "a7a6"}
  end


end

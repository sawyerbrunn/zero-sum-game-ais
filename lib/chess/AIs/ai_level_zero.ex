defmodule LiveTest.Chess.AILevelZero do
  @moduledoc """
  AI "Level 0" Chess engine that is able to choose
  a random move from the list of legal moves.any()

  The idea here is to do server-side move computation
  to reduce the load on browsers, and stop javascript
  threads from being clogged by the current JS minimax
  code.

  A better solution may just be to use web-workers and support
  nonconcurrent move generation.
  """

  alias LiveTest.Chess.Move


  # TODO: [Maybe] Implement server-side random move generation
  def find_move(_game_fen, _turn) do
    %Move{source: "a7", target: "a6", display_name: "a7a6"}
  end


end

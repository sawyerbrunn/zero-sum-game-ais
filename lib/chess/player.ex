defmodule LiveTest.Chess.Player do
  @moduledoc """
  A chess player.

  A chess player can be:
    - manual (requiring user input)
    - ai_random (an AI that chooses random moves)
    - ai_minimax (an intelligent AI that chooses moves
    based on the minimax algorithm)

  If the player is a minimax AI, a search depth can
  be specified, indicating how many moves that AI will
  look ahead.
  """

  @default_depth 3
  @default_type :minimax_ai
  @supported_types [:ai_minimax, :ai_random, :manual]

  defstruct [
    type: :manual,
    depth: @default_depth
  ]

  def default_depth(), do: @default_depth
  def default_type(), do: @default_type
  def supported?(type), do: type in @supported_types
end

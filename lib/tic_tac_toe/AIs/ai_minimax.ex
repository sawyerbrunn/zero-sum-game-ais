defmodule LiveTest.TicTacToe.AiMinimax do
  @moduledoc """
  An intelligent Tic Tac Toe AI capable of choosing
  the best move on a given board by exploring all
  possible evolutions of the current game state.

  Since the number of states to explore at every node
  in the search tree is small, the only heuristic
  function we really need is wether or not the game is over

  X is the maximizing player. O is the minimizing player.
  """
  @behaviour LiveTest.TicTacToe.Ai
  alias LiveTest.TicTacToe.Board

  @infinity 10 ** 10

  @middle_score 0
  @corner_score 10
  @edge_score 5

  @doc """
  Finds the best move by exploring
  a search tree.
  """
  def find_move(%Board{} = board) do
    turn = board.current_turn
    [move, _score, _depth] = minimax(board, 3, -1 * @infinity, @infinity, turn == "X")
    move
  end

  # Depth at 0
  defp minimax(board, 0, _alpha, _beta, _isMaximizer) do
    [nil, simple_eval(board), 0]
  end

  defp minimax(board, depth, alpha, beta, is_maximizer) do
    case Board.find_winner(board) do
      "X" ->
        # X has won the game
        [nil, @infinity, depth]
      "O" ->
        # O has won nthe game
        [nil, -1 * @infinity, depth]
      _ ->
        # The game is still on!
        state_map = %{
          max_val: -1 * @infinity,
          min_val: @infinity,
          best_move: nil,
          best_depth: 0,
          alpha: alpha,
          beta: beta
        }
        legal_moves = Board.list_legal_moves(board)
        Enum.reduce_while(legal_moves, state_map, fn move, state ->
          next_board = Board.make_move(board, board.current_turn, move)
          [_, child_val, child_depth] = minimax(next_board, depth - 1, state.alpha, state.beta, next_board.current_turn == "X")
          child_state =
            if is_maximizer do
              # Minimax Maximizer
              new_state =
                cond do
                  child_val > state.max_val ->
                    state
                    |> Map.put(:best_depth, 0)
                    |> Map.put(:best_move, move)
                    |> Map.put(:max_val, child_val)
                  child_val == state.max_val and child_depth >= state.best_depth ->
                    state
                    |> Map.put(:best_depth, child_depth)
                    |> Map.put(:best_move, move)
                    |> Map.put(:max_val, child_val)
                  true ->
                    state
                end
              new_state
              |> Map.put(:alpha, Enum.max([new_state.alpha, child_val]))
            else
              # Minimax Minimzer
              new_state =
                cond do
                  child_val < state.min_val ->
                    state
                    |> Map.put(:best_depth, 0)
                    |> Map.put(:best_move, move)
                    |> Map.put(:min_val, child_val)
                  child_val == state.min_val and child_depth >= state.best_depth ->
                    state
                    |> Map.put(:best_depthl, child_depth)
                    |> Map.put(:best_move, move)
                    |> Map.put(:min_val, child_val)
                  true ->
                    state
                end
              new_state
              |> Map.put(:beta, Enum.min([new_state.beta, child_val]))
            end
          if child_state.alpha < child_state.beta do
            {:cont, child_state}
          else
            {:halt, child_state}
          end
        end)
        |> state_to_minimax_leaf_val(is_maximizer)
    end
  end

  defp simple_eval(board) do
    case Board.find_winner(board) do
      "X" -> @infinity
      "O" -> -1 * @infinity
      _ ->
        board.state
        |> Enum.map(fn {index, piece} ->
          score(index, piece)
        end)
        |> Enum.sum()
    end
  end

  defp score(_, nil), do: 0
  defp score(index, "X") when index in [4], do: @middle_score
  defp score(index, "X") when index in [0, 2, 6, 8], do: @corner_score
  defp score(index, "X") when index in [1, 3, 5, 7], do: @edge_score
  defp score(index, "O") when index in [4], do: -1 * @middle_score
  defp score(index, "O") when index in [0, 2, 6, 8], do: -1 * @corner_score
  defp score(index, "O") when index in [1, 3, 5, 7], do: -1 * @edge_score


  defp state_to_minimax_leaf_val(final_state, true), do: [final_state.best_move, final_state.max_val, 0]
  defp state_to_minimax_leaf_val(final_state, false), do: [final_state.best_move, final_state.min_val, 0]

end

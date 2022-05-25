import {evaluateBoard} from "./evaluate_board.js"

function minimax(game, depth, alpha, beta, isMaximizer, score, color) {
  // Depth at 0?
  if (depth === 0) return [null, score];
  var children = game.ugly_moves();
  // No legal moves to consider?
  if (children.length === 0) return [null, (color === 'w') ? Number.POSITIVE_INFINITY : Number.NEGATIVE_INFINITY];

  // Initialize minimax variables
  var maxVal = Number.NEGATIVE_INFINITY;
  var minVal = Number.POSITIVE_INFINITY;
  var currUglyMove, bestMove;
  for (currUglyMove of children) {
    // Note: each child is a move we are considering
    // Play ugly_move, then recurse on the resulting board
    var currMove = game.ugly_move(currUglyMove);
    var newScore = evaluateBoard(game, currMove, score, color);
    var childVal = minimax(game, depth - 1, alpha, beta, !isMaximizer, newScore, color)[1];
    game.undo();

    if (isMaximizer && childVal > maxVal) {
      bestMove = currMove;
      maxVal = childVal;
      alpha = Math.max(childVal, alpha)
      if (alpha >= beta) {
        break;
      }
    } else if (!isMaximizer && childVal < minVal) {
      bestMove = currMove;
      minVal = childVal;
      beta = Math.min(childVal, beta)
      if (alpha >= beta) {
        break;
      }
    }
  }

  return [bestMove, (isMaximizer) ? maxVal : minVal]
}

// API for gettining minimax move
function getMinimaxMove (game, depth, score) {
  var turn = game.turn();
  var adjustedScore = (turn === 'w') ? -score : score
  return minimax(game, depth, Number.NEGATIVE_INFINITY, Number.POSITIVE_INFINITY, true, adjustedScore, turn)[0]
}

export { getMinimaxMove }
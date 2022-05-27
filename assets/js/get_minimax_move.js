import {dynamicEvalGame} from "./evaluate_board.js"

function minimax(game, depth, alpha, beta, isMaximizer, score) {
  // Depth at 0?
  if (depth === 0) return [null, score, 0];
  var children = game.ugly_moves();

  children.sort(function (a, b) {
    return 0.5 - Math.random();
  });
  // No legal moves to consider?
  if (children.length === 0) {
    // No legal moves to consider...
    // TODO: Push this logic into static eval function
    // This returns the remaining depth. We want to choose the move that wins quickest.
    if (game.in_checkmate()) {
      return [null, (game.turn() === 'w') ? Number.NEGATIVE_INFINITY : Number.POSITIVE_INFINITY, depth]
    } else {
      return [null, 0, depth]
    }
  }

  // Initialize minimax variables
  var maxVal = Number.NEGATIVE_INFINITY;
  var minVal = Number.POSITIVE_INFINITY;
  var currUglyMove, bestMove, bestDepth;
  bestMove = children[0];
  bestDepth = 0;
  for (currUglyMove of children) {
    // Note: each child is a move we are considering
    // Play ugly_move, then recurse on the resulting board
    var currMove = game.ugly_move(currUglyMove);
    var newScore = dynamicEvalGame(game, currMove, score);
    var [_, childVal, childDepth] = minimax(game, depth - 1, alpha, beta, !isMaximizer, newScore);
    game.undo();

    // Check if this move is better than any other moves.
    // If this move is equally as good as previous moves,
    // we want to choose the move that gets us to the 
    // highest score as quickly as possible.
    if (isMaximizer) {
      if (childVal > maxVal) {
        bestDepth = 0;
        bestMove = currMove;
        maxVal = childVal;
      } else if (childVal == maxVal && childDepth > bestDepth) {
        bestDepth = childDepth
        bestMove = currMove;
        maxVal = childVal;
      }
      alpha = Math.max(childVal, alpha)
    } else {
      if (childVal < minVal) {
        bestDepth = 0;
        bestMove = currMove;
        minVal = childVal;
      } else if (childVal == minVal && childDepth > bestDepth) {
        bestDepth = childDepth;
        bestMove = currMove;
        minVal = childVal;
      }
      beta = Math.min(childVal, beta)
    }
    // if (isMaximizer && (childVal > maxVal)) {
    //   bestDepth = 0;
    //   bestMove = currMove;
    //   maxVal = childVal;
    //   alpha = Math.max(childVal, alpha)
    // } else if (isMaximizer && childVal === maxVal && childDepth >= bestDepth) {
    //   bestDepth = childDepth
    //   bestMove = currMove;
    //   maxVal = childVal;
    //   alpha = Math.max(childVal, alpha)
    // } else if (!isMaximizer && childVal < minVal) {
    //   bestDepth = 0;
    //   bestMove = currMove;
    //   minVal = childVal;
    //   beta = Math.min(childVal, beta)
    // } else if (!isMaximizer && childVal === minVal && childDepth >= bestDepth) {
    //   bestDepth = childDepth;
    //   bestMove = currMove;
    //   minVal = childVal;
    //   beta = Math.min(childVal, beta)
    // }

    if (shouldPrune(alpha, beta)) {
      break;
    }
  }

  return [bestMove, (isMaximizer) ? maxVal : minVal, 0]
}

// Don't prune on infinites, so we can checkmate ASAP
function shouldPrune(alpha, beta) {
  return alpha >= beta && alpha != Number.POSITIVE_INFINITY && beta != Number.NEGATIVE_INFINITY
}

// API for getting a minimax move
function getMinimaxMove (game, depth, score) {
  var turn = game.turn();
  let res = minimax(game, depth, Number.NEGATIVE_INFINITY, Number.POSITIVE_INFINITY, turn === 'w', score)
  console.log(res);
  return res[0];
}

export { getMinimaxMove }
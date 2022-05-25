import {evaluateBoard} from "./evaluate_board.js"

function minimax(game, depth, alpha, beta, isMaximizingPlayer, sum, color) {
    // positionCount++; 
    // console.log('performing minimax!')
    var children = game.ugly_moves();
    
    // Sort moves randomly, so the same move isn't always picked on ties
    if (game.history().length < 4) {
        children.sort(function(a, b){return 0.5 - Math.random()});
    }
    
    var currMove;
    // Maximum depth exceeded or node is a terminal node (no children)
    if (depth === 0 || children.length === 0)
    {
        return [null, sum]
    }

    // Find maximum/minimum from list of 'children' (possible moves)
    var maxValue = Number.NEGATIVE_INFINITY;
    var minValue = Number.POSITIVE_INFINITY;
    var bestMove;
    for (var i = 0; i < children.length; i++)
    {
        currMove = children[i];

        // Note: in our case, the 'children' are simply modified game states
        var currPrettyMove = game.ugly_move(currMove);
        var newSum = evaluateBoard(game, currPrettyMove, sum, color);
        var [childBestMove, childValue] = minimax(game, depth - 1, alpha, beta, !isMaximizingPlayer, newSum, color);
        
        game.undo();
    
        if (isMaximizingPlayer)
        {
            if (childValue > maxValue)
            {
                maxValue = childValue;
                bestMove = currPrettyMove;
            }
            if (childValue > alpha)
            {
                alpha = childValue;
            }
        }

        else
        {
            if (childValue < minValue)
            {
                minValue = childValue;
                bestMove = currPrettyMove;
            }
            if (childValue < beta)
            {
                beta = childValue;
            }
        }

        // Alpha-beta pruning
        if (alpha >= beta)
        {
            break;
        }
    }

    if (isMaximizingPlayer)
    {
        return [bestMove, maxValue]
    }
    else
    {
        return [bestMove, minValue];
    }
}

function other(color) {
    if (color === 'w') {
        return 'b'
    } else {
        return 'w'
    }
}

// AI Functions
function getMinimaxMove (game, depth, prevSum) {
    
    var move;
    var score;

    var startSum;
    if (game.turn() === 'w') {
        startSum = -prevSum
    } else {
        startSum = prevSum
    }

    var result = minimax(game, depth, Number.NEGATIVE_INFINITY, Number.POSITIVE_INFINITY, true, startSum, game.turn());

    move = result[0];
    score = result[1];

    return move;
}

export { getMinimaxMove }
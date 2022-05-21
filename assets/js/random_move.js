// AI Functions
function makeRandomMove (game, board) {
    let possibleMoves = game.moves();

    // game over
    if (possibleMoves.length === 0) {
        return;
    }

    const randomIdx = Math.floor(Math.random() * possibleMoves.length);
    game.move(possibleMoves[randomIdx]);
    board.setPosition(game.fen());
}


export { makeRandomMove };
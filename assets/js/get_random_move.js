// AI Functions
function getRandomMove (game) {
    let possibleMoves = game.moves();

    // console.log(possibleMoves);

    // game over
    if (possibleMoves.length === 0) {
        return;
    }

    const randomIdx = Math.floor(Math.random() * possibleMoves.length);
    // game.move(possibleMoves[randomIdx]);
    // board.setPosition(game.fen());
    return possibleMoves[randomIdx];
}


export { getRandomMove };
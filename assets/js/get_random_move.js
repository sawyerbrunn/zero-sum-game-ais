// AI Functions
function getRandomMove (game) {
    let possibleMoves = game.moves();

    // game over
    if (possibleMoves.length === 0) {
        return;
    }

    const randomIdx = Math.floor(Math.random() * possibleMoves.length);
    return game.move(possibleMoves[randomIdx]);
}

export { getRandomMove };
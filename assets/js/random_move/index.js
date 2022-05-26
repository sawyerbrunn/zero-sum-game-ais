// import { Chess } from "chess.js";

// import Chess from "chess.js"

// require('chess.js');

// const fetch = require("node-fetch");
// fetch('https://cdnjs.cloudflare.com/ajax/libs/chess.js/0.10.3/chess.min.js')

import { Chess } from "chess.js"

let getRandomMove = function(fen) {
    var game = new Chess(fen);
    return game.fen();
}

export { getRandomMove };

// NodeJS.call({"random_move", :randomMove}, ["rnbqkbnr/pppppppp/8/8/7P/8/PPPPPPP1/RNBQKBNR b KQkq h3 0 1"])
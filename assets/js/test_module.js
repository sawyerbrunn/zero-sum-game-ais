
// import { Chess } from "chess.js";

const Chess = require("chess.js")

exports.randomMove = function(fen) {
    game = new Chess(fen);

    return "b6b4"
}
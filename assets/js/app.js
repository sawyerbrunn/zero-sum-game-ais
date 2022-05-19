// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
// import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import { Chess } from 'chess.js'

let hooks = {}
hooks.chessBoard = {
  mounted() {
    // CHESS CODE BELOW

    // NOTE: this example uses the chess.js library:
    // https://github.com/jhlywa/chess.js

    const board = document.querySelector('chess-board');
    const game = new Chess();

    var mount = this;


    // HIGHLIGHT LEGAL MOVES LOGIC
    const highlightStyles = document.createElement('style');
    document.head.append(highlightStyles);
    const whiteSquareGrey = '#a9a9a9';
    const blackSquareGrey = '#696969';

    function removeGreySquares() {
      highlightStyles.textContent = '';
    }

    function greySquare(square) {
      const highlightColor = (square.charCodeAt(0) % 2) ^ (square.charCodeAt(1) % 2)
          ? whiteSquareGrey
          : blackSquareGrey;
      
      highlightStyles.textContent += `
        chess-board::part(${square}) {
          background-color: ${highlightColor};
        }
      `;
    }

    // PICK UP PIECES LOGIC
    board.addEventListener('drag-start', (e) => {
      const {source, piece} = e.detail;

      // do not pick up pieces if the game is over
      if (game.game_over()) {
        e.preventDefault();
        return;
      }

      // or if it's not that side's turn
      if ((game.turn() === 'w' && piece.search(/^b/) !== -1) ||
          (game.turn() === 'b' && piece.search(/^w/) !== -1)) {
        e.preventDefault();
        return;
      }
    });

    // DROP PIECES LOGIC
    board.addEventListener('drop', (e) => {
      const {source, target, setAction} = e.detail;

      removeGreySquares();

      // see if the move is legal
      const move = game.move({
        from: source,
        to: target,
        promotion: 'q' // NOTE: always promote to a queen for example simplicity
      });

      checkGameOver();

      if (game.game_over()) {
        return
      }

      // illegal move
      if (move === null) {
        setAction('snapback');
      } else {
        // make random legal move for black
        window.setTimeout(makeRandomMove, 250);
        checkGameOver();
      }
    });

    function checkGameOver() {
      if (game.game_over()) {
        const winner = other(game.turn());
        const gameOverReason = getGameOverReason();
        console.log('Game Over!');
        console.log(winner);
        console.log(gameOverReason);
        // send message to the server
        mount.pushEvent("game-over", {winner, gameOverReason})
      }
    }

    function other(color) {
      if (color == 'b') {
        return 'w'
      } else {
        return 'b'
      }
    }

    function getGameOverReason() {
      if (game.in_checkmate()) {
        return 'checkmate';
      } else if (game.in_draw()) {
        return 'draw';
      } else if (game.in_stalemate()) {
        return 'stalemate';
      } else if (game.in_threefold_repetition()) {
        return 'threefold_repetition';
      } else if (game.insufficient_material()) {
        return 'insufficient_material';
      }
    }

    board.addEventListener('mouseover-square', (e) => {
      const {square, piece} = e.detail;

      // get list of possible moves for this square
      const moves = game.moves({
        square: square,
        verbose: true
      });

      // exit if there are no moves available for this square
      if (moves.length === 0) {
        return;
      }

      // highlight the square they moused over
      greySquare(square);

      // highlight the possible squares for this piece
      for (const move of moves) {
        greySquare(move.to);
      }
    });

    board.addEventListener('mouseout-square', (e) => {
      removeGreySquares();
    });

    board.addEventListener('snap-end', (e) => {
      board.setPosition(game.fen())
    });

    // CUSTOM TO HTML

    document.querySelector('#setStartBtn').addEventListener('click', () => {
        game.reset();

        board.setPosition(game.fen())
      });

      document.querySelector('#undoBtn').addEventListener('click', () => {
        game.undo()
        game.undo()

        board.setPosition(game.fen());
      });


    // AI Functions
    function makeRandomMove () {
      let possibleMoves = game.moves();

      // game over
      if (possibleMoves.length === 0) {
          return;
      }

      const randomIdx = Math.floor(Math.random() * possibleMoves.length);
      game.move(possibleMoves[randomIdx]);
      board.setPosition(game.fen());
    }


  }
}



let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


// // CHESS CODE BELOW

// // NOTE: this example uses the chess.js library:
// // https://github.com/jhlywa/chess.js

// const board = document.querySelector('chess-board');
// const game = new Chess();


// // HIGHLIGHT LEGAL MOVES LOGIC
// const highlightStyles = document.createElement('style');
// document.head.append(highlightStyles);
// const whiteSquareGrey = '#a9a9a9';
// const blackSquareGrey = '#696969';

// function removeGreySquares() {
//   highlightStyles.textContent = '';
// }

// function greySquare(square) {
//   const highlightColor = (square.charCodeAt(0) % 2) ^ (square.charCodeAt(1) % 2)
//       ? whiteSquareGrey
//       : blackSquareGrey;
  
//   highlightStyles.textContent += `
//     chess-board::part(${square}) {
//       background-color: ${highlightColor};
//     }
//   `;
// }

// // PICK UP PIECES LOGIC
// board.addEventListener('drag-start', (e) => {
//   const {source, piece} = e.detail;

//   // do not pick up pieces if the game is over
//   if (game.game_over()) {
//     e.preventDefault();
//     return;
//   }

//   // or if it's not that side's turn
//   if ((game.turn() === 'w' && piece.search(/^b/) !== -1) ||
//       (game.turn() === 'b' && piece.search(/^w/) !== -1)) {
//     e.preventDefault();
//     return;
//   }
// });

// // DROP PIECES LOGIC
// board.addEventListener('drop', (e) => {
//   const {source, target, setAction} = e.detail;

//   removeGreySquares();

//   // see if the move is legal
//   const move = game.move({
//     from: source,
//     to: target,
//     promotion: 'q' // NOTE: always promote to a queen for example simplicity
//   });

//   checkGameOver();

//   // illegal move
//   if (move === null) {
//     setAction('snapback');
//   } else {
//     // make random legal move for black
//     window.setTimeout(makeRandomMove, 250);
//     checkGameOver();
//   }
// });

// function checkGameOver() {
//   if (game.game_over()) {
//     const winner = other(game.turn());
//     const gameOverReason = getGameOverReason();
//     console.log('Game Over!');
//     console.log(winner);
//     console.log(gameOverReason);
//     // send message to the server
//   }
// }

// function other(color) {
//   if (color == 'b') {
//     return 'w'
//   } else {
//     return 'b'
//   }
// }

// function getGameOverReason() {
//   if (game.in_checkmate()) {
//     return 'checkmate';
//   } else if (game.in_draw()) {
//     return 'draw';
//   } else if (game.in_stalemate()) {
//     return 'stalemate';
//   } else if (game.in_threefold_repetition()) {
//     return 'threefold_repetition';
//   } else if (game.insufficient_material()) {
//     return 'insufficient_material';
//   }
// }

// board.addEventListener('mouseover-square', (e) => {
//   const {square, piece} = e.detail;

//   // get list of possible moves for this square
//   const moves = game.moves({
//     square: square,
//     verbose: true
//   });

//   // exit if there are no moves available for this square
//   if (moves.length === 0) {
//     return;
//   }

//   // highlight the square they moused over
//   greySquare(square);

//   // highlight the possible squares for this piece
//   for (const move of moves) {
//     greySquare(move.to);
//   }
// });

// board.addEventListener('mouseout-square', (e) => {
//   removeGreySquares();
// });

// board.addEventListener('snap-end', (e) => {
//   board.setPosition(game.fen())
// });

// // CUSTOM TO HTML

// document.querySelector('#setStartBtn').addEventListener('click', () => {
//     game.reset();

//     board.setPosition(game.fen())
//   });

//   document.querySelector('#undoBtn').addEventListener('click', () => {
//     game.undo()
//     game.undo()

//     board.setPosition(game.fen());
//   });


// // AI Functions
// function makeRandomMove () {
//   let possibleMoves = game.moves();

//   // game over
//   if (possibleMoves.length === 0) {
//       return;
//   }

//   const randomIdx = Math.floor(Math.random() * possibleMoves.length);
//   game.move(possibleMoves[randomIdx]);
//   board.setPosition(game.fen());
// }


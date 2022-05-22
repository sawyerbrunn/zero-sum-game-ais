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
import { Chess } from "chess.js"
require('@chrisoakman/chessboardjs/dist/chessboard-1.0.0.min.js')

// AI Helpers
// import { makeRandomMove } from 'makeRandomMove'
import { getRandomMove } from "./get_random_move"
import { getMinimaxMove } from "./get_minimax_move"


let hooks = {}
hooks.myBoard = {
  mounted() {
    var mount = this;
    // CHESS CODE BELOW

    // NOTE: this example uses the chess.js library:
    // https://github.com/jhlywa/chess.js

    var board = null
    var game = new Chess()
    var $status = $('#status')
    var $fen = $('#fen')
    var $pgn = $('#pgn')

    window.game = game;

    var whiteSquareGrey = '#a9a9a9'
    var blackSquareGrey = '#696969'

    function removeGreySquares () {
      $('#myBoard .square-55d63').css('background', '')
    }

    function greySquare (square) {
      var $square = $('#myBoard .square-' + square)

      var background = whiteSquareGrey
      if ($square.hasClass('black-3c85d')) {
        background = blackSquareGrey
      }

      $square.css('background', background)
    }

    function onDragStart (source, piece) {
      // do not pick up pieces if the game is over
      if (game.game_over()) return false

      // or if it's not that side's turn
      if ((game.turn() === 'w' && piece.search(/^b/) !== -1) ||
          (game.turn() === 'b' && piece.search(/^w/) !== -1)) {
        return false
      }
    }

    function onDrop (source, target) {
      removeGreySquares()

      // see if the move is legal
      var move = game.move({
        from: source,
        to: target,
        promotion: 'q' // NOTE: always promote to a queen for example simplicity
      })

      // illegal move
      if (move === null) {
        return 'snapback'
      } else if (game.turn() === 'b') {
        requestMoveFromServer(game.fen(), game.turn());
        // let aiMove = getRandomMove(game);
        // board.position(game.fen());
        // requestAiMove();
      }
      updateStatus();
    }

    function onMouseoverSquare (square, piece) {
      // get list of possible moves for this square
      var moves = game.moves({
        square: square,
        verbose: true
      })

      // exit if there are no moves available for this square
      if (moves.length === 0) return

      // highlight the square they moused over
      greySquare(square)

      // highlight the possible squares for this piece
      for (var i = 0; i < moves.length; i++) {
        greySquare(moves[i].to)
      }
    }

    function onMouseoutSquare (square, piece) {
      removeGreySquares()
    }

    function onSnapEnd () {
      board.position(game.fen())
    }

    var config = {
      draggable: true,
      position: 'start',
      onDragStart: onDragStart,
      onDrop: onDrop,
      onMouseoutSquare: onMouseoutSquare,
      onMouseoverSquare: onMouseoverSquare,
      onSnapEnd: onSnapEnd
    }
    board = Chessboard('myBoard', config)
    // END CHESSBOARD.JS FUNCTIONS

    window.board = board



    // PUSH EVENTS TO SERVER

    // Asks the server to send a legal move based on the game fen and the current turn.
    function requestMoveFromServer(fen, turn) {
      mount.pushEvent("request-move", {fen, turn});
    }

    function requestAiMove() {
      var move = getMinimaxMove(game, 3);
      game.move(move);
    }

    // HANDLE EVENTS FROM SERVER
    this.handleEvent('refresh-board', (e) => {
      console.log('updating board!')
      board.position(game.fen());
    });

    this.handleEvent('set-fen', (e) => {
      console.log("Setting fen!")
      console.log(e.fen)
      game.load(e.fen)
      board.position(game.fen());
    });

    this.handleEvent('receive-move', (e) => {
      console.log('Received move from server:');
      console.log(e);


      // TODO: implement server-side chess AI
      // var move = game.move({
      //   from: e.source,
      //   to: e.target,
      //   promotion: 'q' // NOTE: always promote to a queen for example simplicity
      // });

      // TEMP FIX FOR NOW
      requestAiMove();

      board.position(game.fen());
    })


    // HTML Helpers
    // BUTTONS
    document.querySelector('#setStartBtn').addEventListener('click', () => {
      game.reset();

      board.position(game.fen());
    });

    document.querySelector('#undoBtn').addEventListener('click', () => {
      game.undo();
      game.undo();

      board.position(game.fen());
    });

    // UPDATE STATUS TAGS 
    function updateStatus () {
      var status = ''
    
      var moveColor = 'White'
      if (game.turn() === 'b') {
        moveColor = 'Black'
      }
    
      // checkmate?
      if (game.in_checkmate()) {
        status = 'Game over, ' + moveColor + ' is in checkmate.'
      }
    
      // draw?
      else if (game.in_draw()) {
        status = 'Game over, drawn position'
      }
    
      // game still on
      else {
        status = moveColor + ' to move'
    
        // check?
        if (game.in_check()) {
          status += ', ' + moveColor + ' is in check'
        }
      }
    
      $status.html(status);
      $fen.html(game.fen());
      $pgn.html(game.pgn());
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
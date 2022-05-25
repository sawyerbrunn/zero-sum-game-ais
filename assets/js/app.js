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
import { Chess } from "./chess.js"
require('@chrisoakman/chessboardjs/dist/chessboard-1.0.0.min.js')

// AI Helpers
import { getRandomMove } from "./get_random_move"
import { getMinimaxMove } from "./get_minimax_move"
import { evaluateBoard } from "./evaluate_board"


let hooks = {}
hooks.myBoard = {
  mounted() {
    var mount = this;
    // CHESS CODE BELOW
    // NOTE: The code below is an adaptation of the chessboard-js examples 5000-5005
    // https://chessboardjs.com/examples#5000

    var board = null;
    var $board = $('#myBoard');
    var game = new Chess();
    var squareClass = 'square-55d63';
    var $status = $('#status');
    var $fen = $('#fen');
    var $pgn = $('#pgn');
    var playingAiBattle = false;
    window.globalSum = 0;

    // Initialize player types (can be changed by user)
    window.whitePlayerType = 'manual';
    window.whitePlayerDepth = null;
    window.blackPlayerType = 'ai_minimax';
    window.blackPlayerDepth = 3;

    window.game = game;

    const whiteSquareGrey = '#a9a9a9';
    const blackSquareGrey = '#696969';

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

    function highlightWhiteMove(from, to) {
      // highlight white's move
      removeHighlights('white')
      $board.find('.square-' + from).addClass('highlight-white')
      $board.find('.square-' + to).addClass('highlight-white')
    };

    function highlightBlackMove(from, to) {
      // highlight white's move
      removeHighlights('black')
      $board.find('.square-' + from).addClass('highlight-black')
      $board.find('.square-' + to).addClass('highlight-black')
    };
    // color is 'white' or 'black'
    function removeHighlights (color) {
      $board.find('.' + squareClass)
        .removeClass('highlight-' + color)
    }

    // remove all highlighs from squares
    function removeAllHighlights() {
      removeHighlights('white');
      removeHighlights('black');
      squareToHighlight = null;
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

    // TODO: Allow dynamic piece promotion
    function onDrop (source, target) {
      let currentTurn = game.turn();
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
      } else {
        window.globalSum = evaluateBoard(game, move, window.globalSum); // IDK why this is 'b'
      }
      if (game.turn() === 'b' && window.blackPlayerType != 'manual') {
        window.setTimeout(function() {
          requestMoveFromServer(game.fen(), game.turn());
        }, 250);
      } else if (game.turn() === 'w' && window.whitePlayerType != 'manual') {
        window.setTimeout(function() {
          requestMoveFromServer(game.fen(), game.turn());
        }, 250);
    }

      if (currentTurn === 'w') {
        highlightWhiteMove(source, target);
      } else if (currentTurn === 'b') {
        highlightBlackMove(source, target);
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
      board.position(game.fen());
    }

    // // NOTE: This is hard-coded for black as an AI
    // function onMoveEnd () {
    //   $board.find('.square-' + squareToHighlight)
    //     .addClass('highlight-black')
    // }

    var config = {
      draggable: true,
      position: 'start',
      onDragStart: onDragStart,
      onDrop: onDrop,
      // onMoveEnd: onMoveEnd,
      onMouseoutSquare: onMouseoutSquare,
      onMouseoverSquare: onMouseoverSquare,
      onSnapEnd: onSnapEnd
    }
    board = Chessboard('myBoard', config)
    $(window).resize(board.resize);

    // END CHESSBOARD.JS FUNCTIONS

    window.board = board;
    updateStatus();



    // PUSH EVENTS TO SERVER

    // Asks the server to send a legal move based on the game fen and the current turn.
    function requestMoveFromServer(fen, turn) {
      mount.pushEvent("request-move", {fen, turn});
    }

    function pushHistory(history) {
      mount.pushEvent("update-history", {history});
    };

    // function announceGameOver(status) {
    //   mount.pushEvent("game-over", {status});
    // }

    function requestAiMove() {
      let currentTurn = game.turn();
      if (currentTurn === 'w') {
        // highlight white AI's move
        let move = getWhiteAiMove(game);
        game.move(move);
        window.globalSum = evaluateBoard(game, move, window.globalSum);
        highlightWhiteMove(move.from, move.to);
      } else {
        // highlight black AI's move
        let move = getBlackAiMove(game);
        let attempt = game.move(move);
        if (attempt == null) {
          alert('AI function returned illegal move!')
        }
        window.globalSum = evaluateBoard(game, move, window.globalSum);
        highlightBlackMove(move.from, move.to);
      }
      board.position(game.fen());
    }

    function getWhiteAiMove(game) {
      if (whitePlayerType === 'manual') {
        alert('white AI move called, but player type is manual!')
        return
      } else if (whitePlayerType === 'ai_random') {
        return getRandomMove(game);
      } else if (whitePlayerType === 'ai_minimax') {
        return getMinimaxMove(game, whitePlayerDepth, window.globalSum);
      }
    }

    function getBlackAiMove(game) {
      if (blackPlayerType === 'manual') {
        return
      } else if (blackPlayerType === 'ai_random') {
        return getRandomMove(game);
      } else if (blackPlayerType === 'ai_minimax') {
        return getMinimaxMove(game, blackPlayerDepth, window.globalSum);
      }
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
      window.globalSum = 0; // TODO: Update correctly
      removeAllHighlights();
      updateStatus();
    });

    this.handleEvent('update-black-player-settings', (e) => {
      window.blackPlayerType = e.type;
      window.blackPlayerDepth = e.depth;
    });

    this.handleEvent('update-white-player-settings', (e) => {
      window.whitePlayerType = e.type;
      window.whitePlayerDepth = e.depth;
    });

    this.handleEvent('toggle-ai-battle', (_e) => {
      playingAiBattle = !playingAiBattle;
      console.log('Beginning AI heads up battle!');
      window.setTimeout(doAiBattle, 500);
    });

    this.handleEvent('receive-move', (e) => {
      // console.log('Received move from server:');
      // console.log(e);


      // TODO: implement server-side chess AI
      // var move = game.move({
      //   from: e.source,
      //   to: e.target,
      //   promotion: 'q' // NOTE: always promote to a queen for example simplicity
      // });

      // TEMP FIX FOR NOW
      window.setTimeout(requestAiMove, 250);

      board.position(game.fen());
      updateStatus();


      // Maybe request another move here
    })


    // HTML Helpers
    // BUTTONS
    document.querySelector('#setStartBtn').addEventListener('click', () => {
      playingAiBattle = false;
      game.reset();
      window.globalSum = 0; // TODO: Update correctly
      board.position(game.fen());
      removeAllHighlights();
      updateStatus();
    });

    document.querySelector('#undoBtn').addEventListener('click', () => {
      playingAiBattle = false;
      if (blackPlayerType === 'manual' && whitePlayerType === 'manual') {
        // only undo once if both players are manual
        game.undo();
      } else {
        // otherwise, undo twice
        game.undo();
        game.undo();
      }

      // TODO: Update global sum
      board.position(game.fen());
      removeAllHighlights();
      updateStatus();
    });

    document.querySelector('#flipBoardBtn').addEventListener('click', () => {
      board.flip();
    });

    // document.querySelector('#aiBtn').addEventListener('click', () => {
    //   playingAiBattle = !playingAiBattle;
    //   console.log('Beginning AI heads up battle!');
    //   window.setTimeout(doAiBattle, 500);
    // });

    function doAiBattle() {
      if (game.game_over()) {
        console.log('Finished AI Battle!')
        return;
      }
      if (!playingAiBattle) {
        // Cancel AI battle if user clicked a button
        return;
      }
      requestAiMove();
      board.position(game.fen());
      updateStatus();
      window.setTimeout(doAiBattle, 500);
    }

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
        // announceGameOver(status);
      }
    
      // draw?
      else if (game.in_draw()) {
        status = 'Game over, drawn position'
        // announceGameOver(status);
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
      pushHistory(game.history());
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
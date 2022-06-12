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
import 'tw-elements';
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import { Chess } from "./chess.js"
require('@chrisoakman/chessboardjs/dist/chessboard-1.0.0.min.js')

// AI Helpers
import { getRandomMove } from "./get_random_move"
import { getMinimaxMove } from "./get_minimax_move"
import { dynamicEvalGame, staticEvalGame } from "./evaluate_board"


let hooks = {}
hooks.myBoard = {
  mounted() {
    var mount = this;
    // CHESS CODE BELOW
    // NOTE: The code below is an adaptation of the chessboard-js examples 5000-5005
    // https://chessboardjs.com/examples#5000

    var normal_move_audio = new Audio('./audio/normal_move.mp3');
    var piece_capture_audio = new Audio('./audio/piece_capture.mp3');

    var board = null;
    var $board = $('#myBoard');
    var game = new Chess();
    var squareClass = 'square-55d63';
    var $status = $('#status');
    var $globalScore = $('#globalScore')
    var $fen = $('#fen');
    var $pgn = $('#pgn');
    var playingAiBattle = false;
    var whiteHighlightedMove, blackHighlightedMove;
    window.globalScore = 0;

    // Initialize player types (can be changed by user)
    window.whitePlayerType = 'manual';
    window.whitePlayerDepth = null;
    window.blackPlayerType = 'ai_minimax';
    window.blackPlayerDepth = 3;

    window.game = game;

    jQuery('#myBoard').on('scroll touchmove touchend touchstart contextmenu', function(e){
      e.preventDefault();
    });

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
      whiteHighlightedMove = [from, to]
    };

    function highlightBlackMove(from, to) {
      // highlight white's move
      removeHighlights('black')
      $board.find('.square-' + from).addClass('highlight-black')
      $board.find('.square-' + to).addClass('highlight-black')
      blackHighlightedMove = [from, to]
    };
    // color is 'white' or 'black'
    function removeHighlights (color) {
      $board.find('.' + squareClass)
        .removeClass('highlight-' + color)

      if (color == 'black') {
        blackHighlightedMove = null;
      } else if (color == 'white') {
        whiteHighlightedMove = null;
      }
    }

    // remove all highlighs from squares
    function removeAllHighlights() {
      removeHighlights('white');
      removeHighlights('black');
      whiteHighlightedMove = null;
      blackHighlightedMove = null;
    }

    function onDragStart (source, piece) {
      // do not pick up pieces if the game is over
      if (game.game_over()) return false

      // or if it's not that side's turn
      if ((game.turn() === 'w' && piece.search(/^b/) !== -1) ||
          (game.turn() === 'b' && piece.search(/^w/) !== -1)) {
        return false
      }
      highlightLegalMoves(source, piece);
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
        playAudio(move);
        window.globalScore = dynamicEvalGame(game, move, window.globalScore);
      }
      if (game.turn() === 'b' && window.blackPlayerType != 'manual') {
        removeHighlights('black');
        window.setTimeout(function() {
          requestMoveFromServer(game.fen(), game.turn());
        }, 250);
      } else if (game.turn() === 'b') {
        removeHighlights('black');
      } else if (game.turn() === 'w' && window.whitePlayerType != 'manual') {
        removeHighlights('white')
        window.setTimeout(function() {
          requestMoveFromServer(game.fen(), game.turn());
        }, 250);
      } else if (game.turn() === 'w') {
        removeHighlights('white');
      }

      if (currentTurn === 'w') {
        highlightWhiteMove(source, target);
      } else if (currentTurn === 'b') {
        highlightBlackMove(source, target);
      }
      updateStatus();
    }

    function highlightLegalMoves(square, piece) {
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

    function onMouseoverSquare (square, piece) {
      highlightLegalMoves(square, piece);
    }

    function onMouseoutSquare (square, piece) {
      removeGreySquares()
    }

    function onSnapEnd () {
      board.position(game.fen());
    }

    var config = {
      draggable: true,
      position: 'start',
      onDragStart: onDragStart,
      onDrop: onDrop,
      pieceTheme: 'images/{piece}.png',
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

    function pushScore(score) {
      if (score == Number.POSITIVE_INFINITY) {
        mount.pushEvent("update-score", {score: 'inf'});
      } else if (score == Number.NEGATIVE_INFINITY) {
        mount.pushEvent("update-score", {score: '-inf'});
      } else {
        mount.pushEvent("update-score", {score: score});
      }
    }

    // function announceGameOver(status) {
    //   mount.pushEvent("game-over", {status});
    // }

    function requestAiMove() {
      if (game.game_over()) {
        return;
      }
      var currentTurn = game.turn();
      if (currentTurn === 'w') {
        // highlight white AI's move
        var move = getWhiteAiMove(game);
        game.move(move);
        playAudio(move);
        window.globalScore = dynamicEvalGame(game, move, window.globalScore);
        highlightWhiteMove(move.from, move.to);
        if (blackPlayerType == 'manual') {
          removeHighlights('black');
        }
      } else {
        // highlight black AI's move
        var move = getBlackAiMove(game);
        game.move(move);
        playAudio(move);
        window.globalScore = dynamicEvalGame(game, move, window.globalScore);
        highlightBlackMove(move.from, move.to);
        if (whitePlayerType == 'manual') {
          removeHighlights('white');
        }
      }
      board.position(game.fen());
      removeGreySquares();
      updateStatus();
    }

    // If needed, requests an AI move on:
    // (1) New game (if white is manual)
    // (2) Set FEN (if it is an AI's turn)
    // (3) Player updates (if new player is manual)
    function maybeRequestAiMove() {
      if (whitePlayerType != 'manual' && blackPlayerType != 'manual') {
        return;
      } else if (game.turn() === 'w' && whitePlayerType != 'manual') {
        window.setTimeout(requestAiMove, 500);
      } else if (game.turn() === 'b' && blackPlayerType != 'manual') {
        window.setTimeout(requestAiMove, 500);
      }
    }

    function getWhiteAiMove(game) {
      if (whitePlayerType === 'manual') {
        alert('white AI move called, but player type is manual!')
        return
      } else if (whitePlayerType === 'ai_random') {
        return getRandomMove(game);
      } else if (whitePlayerType === 'ai_minimax') {
        return getMinimaxMove(game, whitePlayerDepth, window.globalScore);
      }
    }

    function getBlackAiMove(game) {
      if (blackPlayerType === 'manual') {
        return
      } else if (blackPlayerType === 'ai_random') {
        return getRandomMove(game);
      } else if (blackPlayerType === 'ai_minimax') {
        return getMinimaxMove(game, blackPlayerDepth, window.globalScore);
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
      window.globalScore = staticEvalGame(game);
      removeAllHighlights();
      updateStatus();

      maybeRequestAiMove();
    });

    this.handleEvent('update-black-player-settings', (e) => {
      window.blackPlayerType = e.type;
      window.blackPlayerDepth = e.depth;

      maybeRequestAiMove();
    });

    this.handleEvent('update-white-player-settings', (e) => {
      window.whitePlayerType = e.type;
      window.whitePlayerDepth = e.depth;

      maybeRequestAiMove();
    });

    this.handleEvent('toggle-ai-battle', (_e) => {
      playingAiBattle = !playingAiBattle;
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
      window.globalScore = 0;
      board.position(game.fen());
      removeAllHighlights();
      updateStatus();

      maybeRequestAiMove();
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

      // Update global sum usingn a static eval function
      window.globalScore = staticEvalGame(game);

      board.position(game.fen());
      removeAllHighlights();
      updateStatus();

      maybeRequestAiMove();
    });

    document.querySelector('#flipBoardBtn').addEventListener('click', () => {
      board.flip();
      if (whiteHighlightedMove != null) {
        var from = whiteHighlightedMove[0]
        var to = whiteHighlightedMove[1]
        highlightWhiteMove(from, to)
      }

      if (blackHighlightedMove != null) {
        var from = blackHighlightedMove[0]
        var to = blackHighlightedMove[1]
        highlightBlackMove(from, to);
      }
    });

    function doAiBattle() {
      if (game.game_over()) {
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

    async function playAudio(move) {
      if (move.captured != null) {
        await piece_capture_audio.play();
      } else if (move.color == 'w') {
        await normal_move_audio.play();
      } else if (move.color == 'b') {
        await normal_move_audio.play();
      }
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

      var globalScoreStr;
      if (globalScore >= 500) {
        globalScoreStr = window.globalScore + '. (White is winning!)'
      } else if (globalScore >= 250) {
        globalScoreStr = window.globalScore + '. (White has an advantage)'
      } else if (window.globalScore <= -500) {
        globalScoreStr = window.globalScore + '. (Black is winning!)'
      } else if (window.globalScore <= -250) {
        globalScoreStr = window.globalScore + '. (Black has an advantage)'
      } else {
        globalScoreStr = window.globalScore + '. (It\'s a close game!)'
      }
    
      $status.html(status);
      $globalScore.html(globalScoreStr)
      $fen.html(game.fen());
      $pgn.html(game.pgn());
      pushHistory(game.history());
      pushScore(globalScore);
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
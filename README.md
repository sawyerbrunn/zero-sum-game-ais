# AI Demos - Zero Sum Games
All games are playable at https://sawyerbrunn.com and deployed via Gigalixir.
## About
This project is a demonstration of a few different zero-sum game UIs and how well Minimax AIs can play them.
It currently has chess and tic-tac-toe built out, with plans to build out connect four soon.
## How it's built
This is a Phoenix project that leverages Phoenix LiveView for most web interactions, along with open-source [Tailwind CSS](https://tailwindcss.com/) components such as [tailwind-elements](https://tailwind-elements.com/).

It also uses some amazing open-source node packages available on NPM to handle Chess rules and the general the Chess UI framework:
- [Chessboard.js](https://chessboardjs.com/)
- [Chess.js](https://github.com/jhlywa/chess.js/blob/master/README.md)
- [Jquery](https://github.com/jquery/jquery)

## Running Locally
This project does not require a database, so setup is very simple. 
Follow [these instructions](https://elixir-lang.org/install.html) to install elixir. You may also need to install Node/NPM with `brew install node`.
Then, to run the phoenix server locally:

  * Install elixir dependencies with `mix deps.get`
  * Install node dependencies with `cd assets && npm install && cd ..`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Updated 03/06/2023
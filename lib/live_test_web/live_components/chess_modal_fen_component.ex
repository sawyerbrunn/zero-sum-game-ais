defmodule LiveTest.ChessModalFenComponent do
  @moduledoc """
  A modal for chess game FEN reading and writing.

  This modal should explain what a FEN string is,
  allow users to copy the current chess game's FEN
  string, and allow users to paste a FEN string to
  load any chess game they'd like.
  """
  use Phoenix.LiveComponent
  use Phoenix.HTML


  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end

defmodule LiveTest.ChessModalNewComponent do
  @moduledoc """
  A simple confirmation modal for "New Game"
  button clicks.
  """
  use Phoenix.LiveComponent

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end

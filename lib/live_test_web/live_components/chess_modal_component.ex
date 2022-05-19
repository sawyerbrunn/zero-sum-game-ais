defmodule LiveTest.ChessModalComponent do
  use Phoenix.LiveComponent

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end

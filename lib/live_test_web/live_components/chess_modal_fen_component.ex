defmodule LiveTest.ChessModalFenComponent do
  use Phoenix.LiveComponent

  use Phoenix.HTML


  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end

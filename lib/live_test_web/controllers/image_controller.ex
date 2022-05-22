defmodule LiveTestWeb.ImageController do
  use LiveTestWeb, :controller

  def get_image(conn, %{"file" => file_name} = _params) do
    send_download(conn, {:file, "assets/images/img/chesspieces/wikipedia/" <> file_name})
  end
end

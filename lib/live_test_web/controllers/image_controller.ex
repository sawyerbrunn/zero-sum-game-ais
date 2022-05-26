defmodule LiveTestWeb.ImageController do
  @moduledoc """
  This controller allows JS libraries using jquery to pull
  the correct images for their content.
  """
  use LiveTestWeb, :controller

  def get_image(conn, %{"file" => file_name} = _params) do
    send_download(conn, {:file, "assets/images/img/chesspieces/wikipedia/" <> file_name})
  end
end

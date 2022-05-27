defmodule LiveTestWeb.AudioController do
  @moduledoc """
  This controller allows JS libraries using jquery to pull
  the correct audio files for their content.
  """
  use LiveTestWeb, :controller

  def get_audio(conn, %{"file" => file_name} = _params) do
    # TODO: Dynamic Path
    send_download(conn, {:file, "assets/js/audio/" <> file_name})
  end
end

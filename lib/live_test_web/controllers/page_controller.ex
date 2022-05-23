defmodule LiveTestWeb.PageController do
  use LiveTestWeb, :controller

  # def index(conn, _params) do
  #   render(conn, "index.html")
  # end

  # Just redirect to the primary game for now
  def index(conn, _params) do
    conn |> redirect(to: "/chess") |> halt()
  end

end

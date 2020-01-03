defmodule SeaQuailWeb.PageController do
  use SeaQuailWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

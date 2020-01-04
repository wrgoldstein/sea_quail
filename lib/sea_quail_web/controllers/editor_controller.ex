defmodule SeaQuailWeb.EditorController do
  use SeaQuailWeb, :controller

  def run(conn, params) do
    output = params  # replace with query run
    json(conn, output)
  end
end

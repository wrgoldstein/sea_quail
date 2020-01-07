defmodule SeaQuailWeb.QueryView do
  use SeaQuailWeb, :view

  def truncate_body(body) do
    if String.length(body) <= 60 do
      body
    else
      truncated = String.slice(body, 0, 60)
      "#{truncated}..."
    end
  end

  def render("index.json", %{queries: queries}) do
    %{data: render_many(queries, SeaQuailWeb.QueryView, "show.json")}
  end

  def render("show.json", %{query: query}) do
    edit_path = SeaQuailWeb.Router.Helpers.query_path(SeaQuailWeb.Endpoint, :edit, query.id)
    delete_path = SeaQuailWeb.Router.Helpers.query_path(SeaQuailWeb.Endpoint, :delete, query.id)
    %{
        id: query.id,
        name: query.name,
        body: truncate_body(query.body),
        edit_path: edit_path,
        delete_path: delete_path
    }
  end
end

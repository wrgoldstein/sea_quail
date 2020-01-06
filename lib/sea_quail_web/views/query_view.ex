defmodule SeaQuailWeb.QueryView do
  use SeaQuailWeb, :view

  def truncate_body(body) do
    if String.length(body) <= 30 do
      body
    else
      truncated = Regex.run(~r/\A(.{0,30})(?:-|\Z)/, body) |> List.last()
      "#{truncated}..."
    end
  end

  def render("index.json", %{queries: queries}) do
    %{data: render_many(queries, SeaQuailWeb.QueryView, "show.json")}
  end

  def render("show.json", %{query: query}) do
    %{
        id: query.id,
        name: query.name,
        body: truncate_body(query.body)
    }
  end
end

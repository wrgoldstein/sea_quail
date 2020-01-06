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
end

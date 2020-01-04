defmodule SeaQuailWeb.EditorController do
  use SeaQuailWeb, :controller

  import Guardian.Plug, only: [current_resource: 1]

  @ext_map %{
    Postgrex.Extensions.Raw => "string",
    Postgrex.Extensions.Date => "date",
    Postgrex.Extensions.Timestamp => "date",
    Postgrex.Extensions.Int8 => "number"
  }

  def run(conn, params) do
    user = current_resource(conn)
    query = params["text"]

    case SeaQuail.Pool.Registry.query(user.id, query) do
      {:ok, query, result} ->
        number_indexes =
          query.result_types
          |> Enum.with_index()
          |> Enum.filter(fn {x, _i} -> @ext_map[x] == "number" end)
          |> Enum.map(fn {_x, i} -> i end)

        number_columns =
          query.columns
          |> Enum.with_index()
          |> Enum.filter(fn {_x, i} -> Enum.member?(number_indexes, i) end)
          |> Enum.map(fn {x, _i} -> x end)

        non_number_columns =
          query.columns
          |> Enum.with_index()
          |> Enum.filter(fn {_x, i} -> !Enum.member?(number_indexes, i) end)
          |> Enum.map(fn {x, _i} -> x end)

        result = %{
          number_columns: number_columns,
          non_number_columns: non_number_columns,
          result_types: query.result_types |> Enum.map(fn x -> @ext_map[x] end),
          rows: result.rows,
          columns: result.columns
        }

        json(conn, result)

      {:down, error} ->
        IO.inspect(error)
        send_resp(conn, 500, "Database disconnected")

      {:error, %{postgres: error}} ->
        conn
        |> put_status(500)
        |> json(%{error: error.message})

      {:error, %{message: message}} ->
        send_resp(conn, 500, message)
    end
  end
end

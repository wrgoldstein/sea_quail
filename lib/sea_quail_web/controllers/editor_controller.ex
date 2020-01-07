defmodule SeaQuailWeb.EditorController do
  use SeaQuailWeb, :controller

  import Guardian.Plug, only: [current_resource: 1]

  @ext_map %{
    Postgrex.Extensions.Raw => "string",
    Postgrex.Extensions.Date => "date",
    Postgrex.Extensions.Timestamp => "date",
    Postgrex.Extensions.Int8 => "number",
    Postgrex.Extensions.Float8 => "number"
  }

  def run(conn, params) do
    user = current_resource(conn)
    query = params["text"]

    # hack to ensure limit is included
    
    if check_limit(query) do
      handle_query(conn, user, query)
    else
      conn
            |> put_status(500)
            |> json(%{error: "Must include a LIMIT less than 100"})
    end
  end

  def check_limit(query) do
    capture = Regex.named_captures(~r/limit([[:cntrl:], [:blank:]])+(?<limit>\d+)/im, query)
    not is_nil(capture) and not is_nil(capture["limit"]) and String.to_integer(capture["limit"]) <= 100
  end

  def get_stats(conn, _params) do
    #TODO move this to a separate module
    user = current_resource(conn)

    query1 = """
      select
        table_schema, table_name, column_name, data_type 
      from information_schema.columns
      where table_schema not in ('pg_catalog', 'information_schema')
    """
    {:ok, query, result1} = SeaQuail.Pool.Registry.query(user.id, query1)
    where = result1.rows |> Enum.map(fn row -> 
      "(tablename = '#{List.last(row)}' AND schemaname = '#{List.first(row)}')" 
    end) |> Enum.join(" OR ")
  
    query2 = """
    select 
      schemaname,
      tablename,
      attname,
      inherited,
      null_frac,
      avg_width,
      n_distinct,
      most_common_vals::text::varchar[],
      most_common_freqs::text::varchar[],
      histogram_bounds::text::varchar[]
    from pg_stats
    where #{where}
    """
  
    # {:ok, query, result2} = SeaQuail.Pool.Registry.query(user.id, query2)

    conn
      |> put_status(200)
      |> json(%{
        columns: result1.columns,
        rows: result1.rows
      })
  end

  def handle_query(conn, user, query) do
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

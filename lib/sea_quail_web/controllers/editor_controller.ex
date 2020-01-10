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
    rows = check_limit(user, query)
    if rows <= 500 do
      handle_query(conn, user, query)
    else
      conn
            |> put_status(500)
            |> json(%{error: "Query would return #{rows} rows, try adding a limit to bring it under 500"})
    end
  end

  def check_limit(user, query) do
    case SeaQuail.Pool.Registry.query(user.id, "explain #{query}") do
      {:ok, _, result} ->
        [[head] | _] = result.rows
        Regex.named_captures(~r/rows=(?<rows>\d+)/im, head)["rows"] |> String.to_integer
      _ -> 1
    end
  end

  def get_tables(conn, _params) do
    user = current_resource(conn)
    query = """
      select
        distinct table_schema, table_name
      from information_schema.columns
      where table_schema not in ('pg_catalog', 'information_schema')
    """
    {:ok, _, result} = SeaQuail.Pool.Registry.query(user.id, query)
    conn
      |> put_status(200)
      |> json(%{
        columns: result.columns,
        rows: result.rows
      })

  end

  def get_stats(conn, params) do
    #TODO move this to a separate module    
    user = current_resource(conn)
    tablename = params["selection"]["table"]
    schemaname = params["selection"]["schema"]
    where = "(tablename = '#{tablename}' AND schemaname = '#{schemaname}')" 
    SeaQuail.Pool.Registry.query(user.id, "analyze #{schemaname}.#{tablename};")
    query = """
    select 
      schemaname,
      tablename,
      attname,
      data_type,
      inherited,
      null_frac,
      avg_width,
      n_distinct,
      most_common_vals::text::varchar[],
      most_common_freqs::text::varchar[],
      histogram_bounds::text::varchar[]
    from pg_stats p
      left join information_schema.columns c
        on p.schemaname = c.table_schema
        and p.tablename = c.table_name
        and p.attname = c.column_name
    where #{where}
    """
    {:ok, _query, result} = SeaQuail.Pool.Registry.query(user.id, query)

    conn
      |> put_status(200)
      |> json(%{
        columns: result.columns,
        rows: result.rows
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

      {:down, {:error, %Postgrex.Error{} = error}} ->
          send_resp(conn, 500, error.postgres.message)

      {:error, %{postgres: error}} ->
        send_resp(conn, 500, error.message)

      {:error, %{message: message}} ->
        send_resp(conn, 500, message)

      {:error, %Postgrex.Error{} = error} ->
        send_resp(conn, 500, error.postgres.message)

      {:error, _} ->
        send_resp(conn, 500,  "unknown error")

      {:down, _} ->
        send_resp(conn, 500,  "unknown error")
    end
  end
end

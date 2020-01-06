defmodule SeaQuailWeb.QueryController do
  use SeaQuailWeb, :controller

  alias SeaQuail.Content
  alias SeaQuail.Content.Query
  alias SeaQuailWeb.Guardian

  def index(conn, _params) do
    maybe_user = Guardian.Plug.current_resource(conn)
    queries = Content.list_queries(maybe_user)
    render(conn, "index.json", queries: queries)
  end

  def new(conn, _params) do
    changeset = Content.change_query(%Query{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, query_params) do
    maybe_user = Guardian.Plug.current_resource(conn)
    case Content.create_query(Map.put(query_params, "user_id", maybe_user.id)) do
      {:ok, _query} ->
        conn
        |> put_status(200)
        |> json(%{})
      {:error, %Ecto.Changeset{} = changeset} ->
        errors = [:name, :body]
          |> Enum.reduce(%{}, fn field, acc -> 
            val = Keyword.get_values(changeset.errors, field) |> Enum.map(fn {error, _} -> error end)
            Map.put(acc, field, val)
          end)
        conn
          |> put_status(500)
          |> json(%{error: errors})
    end
  end

  def show(conn, %{"id" => id}) do
    query = Content.get_query!(id)
    render(conn, "show.json", query: query)
  end

  def edit(conn, %{"id" => id}) do
    query = Content.get_query!(id)
    changeset = Content.change_query(query)
    render(conn, "edit.html", query: query, changeset: changeset)
  end

  def update(conn, %{"id" => id, "query" => query_params}) do
    query = Content.get_query!(id)

    case Content.update_query(query, query_params) do
      {:ok, query} ->
        conn
        |> put_flash(:info, "Query updated successfully.")
        |> redirect(to: Routes.query_path(conn, :show, query))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", query: query, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    query = Content.get_query!(id)
    {:ok, _query} = Content.delete_query(query)

    conn
    |> put_flash(:info, "Query deleted successfully.")
    |> redirect(to: Routes.query_path(conn, :index))
  end
end

defmodule SeaQuailWeb.ConnectionController do
  use SeaQuailWeb, :controller

  alias SeaQuail.Accounts
  alias SeaQuail.Accounts.User
  
  import Guardian.Plug, only: [current_resource: 1]

  def edit(conn, _params) do
    user = current_resource(conn)
    connection = Accounts.get_connection_for!(user.id) || %Accounts.Connection{}
    changeset = Accounts.change_connection(connection)
    render(conn, "edit.html", user: user, changeset: changeset, existing: connection)
  end

  def update(conn, %{"connection" => params}) do
    user = current_resource(conn)
    connection = Accounts.get_connection_for!(user.id)
    update(conn, user, connection, params)
  end

  defp update(conn, %User{} = user, old_connection, params) do
    if old_connection do
      Accounts.delete_connection(old_connection)
    end

    case Accounts.create_connection(Map.put(params, "user_id", user.id)) do
      {:ok, _connection} ->
        SeaQuail.Pool.Registry.refresh_connection(user.id)

        conn
        |> put_flash(:info, "Connection added successfully.")
        |> redirect(to: Routes.connection_path(conn, :update))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset, existing: %{})
    end
  end

  defp update(conn, %User{} = user, %Accounts.Connection{} = connection, params) do
    case Accounts.update_connection(connection, user, Map.put(params, "user_id", user.id)) do
      {:ok, _connection} ->
        conn
        |> put_flash(:info, "Connection updated successfully.")
        |> redirect(to: Routes.connection_path(conn, :update))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset, existing: connection)
    end
  end
end

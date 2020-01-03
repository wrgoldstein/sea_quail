defmodule SeaQuailWeb.SessionController do
    use SeaQuailWeb, :controller
  
    alias SeaQuail.Accounts
    alias SeaQuail.Accounts.User
    alias SeaQuailWeb.Guardian
  
    def index(conn, _params) do
      changeset = Accounts.change_user(%User{})
      maybe_user = Guardian.Plug.current_resource(conn)
      conn
      |> render("index.html",
        changeset: changeset,
        action: Routes.session_path(conn, :login),
        maybe_user: maybe_user
      )
    end
  
    def login(conn, %{"user" => %{"email" => username, "password" => password}}) do
      case Accounts.authenticate_user(username, password) do
        {:ok, user} ->
        #   We'll use this later to handle database connections
        #   SeaQuail.Pool.Registry.maybe_start_connection(user.id)
  
          conn
          |> Guardian.Plug.sign_in(user, token_type: :access)
          |> put_flash(:info, "Signed in!")
          |> redirect(to: "/")
  
        {:error, message} ->
          conn
          |> put_flash(:info, message)
          |> redirect(to: "/login")
      end
    end
  
    def logout(conn, _) do
      conn
      |> Guardian.Plug.sign_out()
      |> redirect(to: "/")
    end
  end
  
defmodule SeaQuail.Accounts.Session do
    alias SeaQuail.Accounts.User
  
    def current_user(conn) do
      id = Plug.Conn.get_session(conn, :current_user)
      if id, do: SeaQuail.Repo.get(User, id)
    end
  
    def logged_in?(conn), do: !!current_user(conn)
  end
  
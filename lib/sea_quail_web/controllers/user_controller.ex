defmodule SeaQuailWeb.UserController do
  use SeaQuailWeb, :controller

  alias SeaQuail.Accounts
  alias SeaQuail.Accounts.User
  alias SeaQuailWeb.Guardian

  @github_client_id System.get_env("GITHUB_CLIENT_ID")
  @github_client_secret System.get_env("GITHUB_CLIENT_SECRET")

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user, token_type: :access)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def account(conn, _params) do
    # account details and connection details
    user = Guardian.Plug.current_resource(conn)
    render(conn, "show.html", user: user)
  end
  System.get_env("GITHUB_CLIENT_ID")
  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  def handle_webhook(conn, params) do
    code = params["code"]
    url = "https://github.com/login/oauth/access_token?client_id=#{@github_client_id}&client_secret=#{@github_client_secret}&code=#{code}"
    {:ok, resp} = HTTPoison.post(url, Jason.encode!(%{}))
    if resp.status_code == 200 do
      [_, token | _] = String.split(resp.body, ~r/[=|&]/)

      # TRYING TO DECIDE IF I SHOULD MAKE A USER WITH THIS TOKEN..
      # IF SO, HOW DOES A USER LOG IN?

      # ALTERNATIVELY, SIGN IN WITH AN EMAIL AND *CONNECT* A GITHUB,
      # THEN ALLOW SAVING TO GITHUB IN THE OBVIOUS WAY. THIS SEEMS BETTER.

      # SO TODO:
      #   - MIGRATE USERS TO ADD GITHUB TOKEN
      #   - FIGURE OUT HOW TO MODIFY A REPO (COMMIT, ADD, ETC)
      #   - ASK USER TO ADD A REPO...? SO MORE THAN ONE USER CAN USE THE SAME ONE
      #   - jeez theres actually a huge amount to do
      #   - FIGURE OUT HOW TO add/commit/modify and make pull requests from elixir

    end
    conn
      |> put_flash(:info, "Received webhook")
      |> redirect(to: Routes.user_path(conn, :new))
  end
end

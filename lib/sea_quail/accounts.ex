defmodule SeaQuail.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SeaQuail.Repo

  alias SeaQuail.Accounts.{User, Connection}
  alias Comeonin.Bcrypt

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def authenticate_user(email, given_password) do
    with user when not is_nil(user) <- Repo.get_by(User, email: email) do
      check_password(user, given_password)
    else
      _ -> {:error, "Invalid User or Password"}
    end
  end

  defp check_password(nil, _), do: {:error, "Incorrect email or password"}

  defp check_password(user, given_password) do
    case Bcrypt.checkpw(given_password, user.crypted_password) do
      true -> {:ok, user}
      false -> {:error, "Incorrect email or password"}
    end
  end

  def get_connection_for!(session_connection_id) do
    # TODO: Replace user_id with organization_id
    Repo.get_by(Connection, user_id: session_connection_id)
  end

  def change_connection(%Connection{} = connection) do
    Connection.changeset(connection, %{})
  end

  def update_connection(%Connection{} = connection, _user, attrs) do
    connection
    |> Connection.changeset(attrs)
    |> Repo.update()
  end

  def delete_connection(%Connection{} = connection) do
    Repo.delete(connection)
  end

  def create_connection(attrs) do
    %Connection{}
    |> Connection.changeset(attrs)
    |> Repo.insert()
  end
end

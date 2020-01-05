defmodule SeaQuail.Accounts.Connection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "connections" do
    field(:hostname, :string)
    field(:database, :string)
    field(:username, :string)
    field(:password, :string)
    field(:port, :string)

    belongs_to(:user, SeaQuail.Accounts.User)

    timestamps()
  end

  @valid_fields ~w(user_id hostname database username password port)a
  @required_fields ~w(hostname database)a

  @doc false
  def changeset(connection, attrs) do
    connection
    |> cast(attrs, @valid_fields)
    |> validate_required(@required_fields)
  end

  def as_json(connection) do
    %{
       hostname: connection.hostname,
       database: connection.database,
       username: connection.username,
       password: connection.password,
       port: connection.port
     }
  end
end

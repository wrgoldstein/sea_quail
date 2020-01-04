defmodule SeaQuail.Repo.Migrations.CreateConnections do
  use Ecto.Migration

  def change do
    create table(:connections) do
      add :hostname, :string
      add :database, :string
      add :username, :string
      add :password, :string
      add :port, :string
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps()
    end
  end
end

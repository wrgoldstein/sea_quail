defmodule SeaQuail.Repo.Migrations.CreateQueries do
  use Ecto.Migration

  def change do
    create table(:queries) do
      add :name, :string
      add :body, :text
      add :user_id, references(:users, on_delete: :nothing)
      
      timestamps()
    end
  end
end

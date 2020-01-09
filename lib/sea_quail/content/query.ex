defmodule SeaQuail.Content.Query do
  use Ecto.Schema
  import Ecto.Changeset

  schema "queries" do
    field :body, :string
    field :name, :string
    belongs_to(:user, SeaQuail.Accounts.User)
    timestamps()
  end

  @doc false
  def changeset(query, attrs) do
    query
    |> cast(attrs, [:name, :body, :user_id])
    |> validate_required([:name, :body, :user_id])
  end
end

defmodule SeaQuail.Content.Query do
  use Ecto.Schema
  import Ecto.Changeset

  schema "queries" do
    field :body, :string
    field :name, :string
    field :user_id, :string

    timestamps()
  end

  @doc false
  def changeset(query, attrs) do
    query
    |> cast(attrs, [:name, :body, :user_id])
    |> validate_required([:name, :body, :user_id])
    |> unique_constraint(:email)
  end
end

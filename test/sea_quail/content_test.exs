defmodule SeaQuail.ContentTest do
  use SeaQuail.DataCase

  alias SeaQuail.Content

  describe "queries" do
    alias SeaQuail.Content.Query

    @valid_attrs %{body: "some body", name: "some name", user_id: "some user_id"}
    @update_attrs %{body: "some updated body", name: "some updated name", user_id: "some updated user_id"}
    @invalid_attrs %{body: nil, name: nil, user_id: nil}

    def query_fixture(attrs \\ %{}) do
      {:ok, query} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_query()

      query
    end

    test "list_queries/0 returns all queries" do
      query = query_fixture()
      assert Content.list_queries() == [query]
    end

    test "get_query!/1 returns the query with given id" do
      query = query_fixture()
      assert Content.get_query!(query.id) == query
    end

    test "create_query/1 with valid data creates a query" do
      assert {:ok, %Query{} = query} = Content.create_query(@valid_attrs)
      assert query.body == "some body"
      assert query.name == "some name"
      assert query.user_id == "some user_id"
    end

    test "create_query/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_query(@invalid_attrs)
    end

    test "update_query/2 with valid data updates the query" do
      query = query_fixture()
      assert {:ok, %Query{} = query} = Content.update_query(query, @update_attrs)
      assert query.body == "some updated body"
      assert query.name == "some updated name"
      assert query.user_id == "some updated user_id"
    end

    test "update_query/2 with invalid data returns error changeset" do
      query = query_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_query(query, @invalid_attrs)
      assert query == Content.get_query!(query.id)
    end

    test "delete_query/1 deletes the query" do
      query = query_fixture()
      assert {:ok, %Query{}} = Content.delete_query(query)
      assert_raise Ecto.NoResultsError, fn -> Content.get_query!(query.id) end
    end

    test "change_query/1 returns a query changeset" do
      query = query_fixture()
      assert %Ecto.Changeset{} = Content.change_query(query)
    end
  end
end

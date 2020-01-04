defmodule SeaQuail.Pool do
  use Agent

  Postgrex.Types.define(SeaQuail.PostgrexTypes, [], json: Jason)

  def start_link(connection) do
    Agent.start_link(fn -> connect(connection) end, name: __MODULE__)
  end

  def query(sql) do
    Agent.get(__MODULE__, fn pid ->
      Postgrex.query(pid, sql, [], pool: DBConnection.Poolboy)
    end)
  end
  
  def connect(nil) do
    {:error, "No connection set"}
  end

  def connect(connection) do
    params = %{
      pool: DBConnection.Poolboy,
      name: :"#{__MODULE__}_Poolboy",
      pool_size: 8,
      hostname: connection.hostname,
      username: connection.username,
      database: connection.database,
      port: connection.port,
      password: connection.password,
      ssl: connection.hostname != "localhost",
      # On Postgrex >= 0.14 this was made easier:
      # config :postgrex, :json_library, Poison
      # but we are on 0.13 for now
      types: SeaQuail.PostgrexTypes
    }

    # When connecting to localost for development purposes
    params = :maps.filter(fn _, v -> v != nil end, params) |> Keyword.new()
    {:ok, pid} = Postgrex.start_link(params)
    pid
  end
end

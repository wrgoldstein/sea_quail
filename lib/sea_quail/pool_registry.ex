defmodule SeaQuail.Pool.Registry do
  use GenServer

  alias DBConnection.ConnectionPool

  def start_link(_ignore \\ nil) do
    GenServer.start_link(__MODULE__, %{}, name: PoolRegistry)
  end

  @impl true
  def init(_unused) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, session_connection_id}, _from, session_connection_ids) do
    {:reply, Map.fetch(session_connection_ids, session_connection_id), session_connection_ids}
  end

  @impl true
  def handle_cast({:create, session_connection_id}, session_connection_ids) do
    if Map.has_key?(session_connection_ids, session_connection_id) do
      {:noreply, session_connection_ids}
    else
      connection = SeaQuail.Accounts.get_connection_for!(session_connection_id)
      pid = case SeaQuail.Pool.start_link(connection) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end
      {:noreply, Map.put(session_connection_ids, session_connection_id, pid)}
    end
  end

  @impl true
  def handle_cast({:refresh, session_connection_id}, session_connection_ids) do
    connection = SeaQuail.Accounts.get_connection_for!(session_connection_id)
    {:ok, pool} = SeaQuail.Pool.start_link(connection)
    {:noreply, Map.put(session_connection_ids, session_connection_id, pool)}
  end

  def refresh_connection(session_connection_id) do
    GenServer.cast(PoolRegistry, {:refresh, session_connection_id})
  end

  def maybe_start_connection(session_connection_id) do
    case GenServer.call(PoolRegistry, {:lookup, session_connection_id}) do
      :error ->
        GenServer.cast(PoolRegistry, {:create, session_connection_id})
        GenServer.call(PoolRegistry, {:lookup, session_connection_id})
      {:ok, pid} ->
        {:ok, pid}
    end
  end

  def query(session_connection_id, sql) do
    {:ok, pid} = maybe_start_connection(session_connection_id)
    Agent.get(pid, fn pool ->
      try do
        with \
          {:ok, query} <- Postgrex.prepare(pool, "unnamed", sql, pool: ConnectionPool, timeout: 1500),
          {:ok, result} <- Postgrex.execute(pool, query, [], pool: ConnectionPool)
          do
            %{ query: query, result: result}
          else
            err -> 
              IO.puts("PoolRegistry Error running query")
              IO.inspect(err)
          end
      rescue
        err -> {:down, err}
      end
    end)
  end
end

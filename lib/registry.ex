defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Start the registry
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Look up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.

  ## Examples

      iex> KV.Registry.lookup(KV.Registry, "bag_of_tricks")
      {:ok, pid}

  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Look up all the bucket pids stored in server

  ## Examples

      iex> KV.Registry.read_all(KV.Registry)
      %{
        "server_name" => pid
      }

  """
  def read_all(server) do
    GenServer.call(server, {:read_all})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.

  ## Examples

      iex> KV.Registry.create(KV.Registry, "bag_of_tricks")
      :ok

  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Defining genserver callbacks

  @impl true
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_call({:read_all}, _from, state) do
    {names, _} = state
    {:reply, names, state}
  end

  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      {:noreply, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")
    {:noreply, state}
  end
end

defmodule KV.Bucket do
  use Agent, restart: :temporary

  @doc """
  Start a new bucket
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Get a value from the `bucket` by `key`
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Put the `value` for the given `key` in the `bucket`
  """
  def put(bucket, key, value) do
    Agent.update(bucket, fn state ->
      Map.put(state, key, value)
    end)
  end

  @doc """
  Delete `key` from `bucket`

  Returns the current vlue of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn dict ->
      Process.sleep(1000)
      Map.pop(dict, key)
    end)
  end
end

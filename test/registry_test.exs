defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(KV.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    # Check that the bucket doesn't exist
    assert KV.Registry.lookup(registry, "shopping") == :error

    # Create the bucket
    KV.Registry.create(registry, "shopping")

    # Check bucket exists
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    # Add key and value to bucket
    KV.Bucket.put(bucket, "milk", 1)

    # Assert key and value was added
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket, :shutdown)
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end

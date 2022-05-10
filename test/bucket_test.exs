defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    # Check for key, should be empty
    assert KV.Bucket.get(bucket, "milk") == nil

    # Add key with value
    KV.Bucket.put(bucket, "milk", 3)

    # Check value is 3
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "delete values by key", %{bucket: bucket} do
    # Check for key, should be empty
    assert KV.Bucket.get(bucket, "milk") == nil

    # Add key with value
    KV.Bucket.put(bucket, "milk", 3)

    # Check value is 3
    assert KV.Bucket.get(bucket, "milk") == 3

    # Remove key
    KV.Bucket.delete(bucket, "milk")

    # Check key is removed
    assert KV.Bucket.get(bucket, "milk") == nil
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end

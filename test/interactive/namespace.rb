require "./test/helper"

require File.expand_path("../../lib/interactive/namespace", File.dirname(__FILE__))

scope do
  test "Namespace for static arguments" do
    assert ["set", "ns:key", "foo"] == \
      Interactive.namespace("ns", ["set", "key", "foo"])

    assert ["ping"] == \
      Interactive.namespace("ns", ["ping"])

    assert ["echo", "foo"] == \
      Interactive.namespace("ns", ["echo", "foo"])
  end

  test "Namespace with optional arguments" do
    assert ["zrange", "ns:key", "0", "-1", "withscores"] == \
      Interactive.namespace("ns", ["zrange", "key", "0", "-1", "withscores"])
  end

  test "Namespace with variable number of arguments" do
    assert ["mset", "ns:key1", "foo", "ns:key2", "foo"] == \
      Interactive.namespace("ns", ["mset", "key1", "foo", "key2", "foo"])

    assert ["hmset", "ns:key1", "field1", "foo", "field2", "bar"] == \
      Interactive.namespace("ns", ["hmset", "key1", "field1", "foo", "field2", "bar"])
  end

  test "Namespace ZUNIONSTORE/ZINTERSTORE" do
    for cmd in %w(zunionstore zinterstore)
      assert [cmd, "ns:dst", "2", "ns:key1", "ns:key2", "weights", "1.0", "2.0"] == \
        Interactive.namespace("ns", [cmd, "dst", "2", "key1", "key2", "weights", "1.0", "2.0"])
    end
  end

  test "Namespace SORT" do
    command = %w(sort key by foo by bar get foo get bar store dst limit 0 10 asc)
    expected = %w(sort ns:key by ns:foo by ns:bar get ns:foo get ns:bar store ns:dst limit 0 10 asc)
    assert expected == Interactive.namespace("ns", command)
  end

  test "Namespace GEORADIUS" do
    command = %w(georadius key 10 20 40 km withcoord store foo storedist bar)
    expected = %w(georadius ns:key 10 20 40 km withcoord store ns:foo storedist ns:bar)
    assert expected == Interactive.namespace("ns", command)
  end
end


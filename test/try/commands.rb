require "./test/helper"

require File.expand_path("../../lib/try/commands", File.dirname(__FILE__))

setup do
  ::Try::Commands.new(commands)
end

scope do
  test "Namespace for static arguments" do |cmds|
    assert ["set", "ns:key", "foo"] == \
      cmds.namespace("ns", ["set", "key", "foo"])

    assert ["ping"] == \
      cmds.namespace("ns", ["ping"])

    assert ["echo", "foo"] == \
      cmds.namespace("ns", ["echo", "foo"])
  end

  test "Namespace with optional arguments" do |cmds|
    assert ["zrange", "ns:key", "0", "-1", "withscores"] == \
      cmds.namespace("ns", ["zrange", "key", "0", "-1", "withscores"])
  end

  test "Namespace with variable number of arguments" do |cmds|
    assert ["mset", "ns:key1", "foo", "ns:key2", "foo"] == \
      cmds.namespace("ns", ["mset", "key1", "foo", "key2", "foo"])

    assert ["hmset", "ns:key1", "field1", "foo", "field2", "bar"] == \
      cmds.namespace("ns", ["hmset", "key1", "field1", "foo", "field2", "bar"])
  end

  test "Namespace ZUNIONSTORE/ZINTERSTORE" do |cmds|
    for cmd in %w(zunionstore zinterstore)
      assert [cmd, "ns:dst", "2", "ns:key1", "ns:key2", "weights", "1.0", "2.0"] == \
        cmds.namespace("ns", [cmd, "dst", "2", "key1", "key2", "weights", "1.0", "2.0"])
    end
  end

  test "Namespace SORT" do |cmds|
    command = %w(sort key by foo by bar get foo get bar store dst limit 0 10 asc)
    expected = %w(sort ns:key by ns:foo by ns:bar get ns:foo get ns:bar store ns:dst limit 0 10 asc)
    assert expected == cmds.namespace("ns", command)
  end
end


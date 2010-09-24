require "json"
require "ruby-debug"

require File.expand_path("../reference", File.dirname(__FILE__))

reference = Reference.new(JSON.parse(File.read("./redis-doc/commands.json")))

setup do
  reference
end

test "DEBUG OBJECT" do |reference|
  res = "DEBUG OBJECT key"
  assert reference["DEBUG OBJECT"].to_s == res
end

test "DEL" do |reference|
  res = "DEL key1 key2 ... keyN"
  assert reference["DEL"].to_s == res
end

test "DISCARD" do |reference|
  res = "DISCARD"
  assert reference["DISCARD"].to_s == res
end

test "SORT" do |reference|
  res = "SORT key [BY pattern] [LIMIT start count] [GET pattern1 GET pattern2" +
        " ... GET patternN] [ASC|DESC] [ALPHA] [STORE destination]"
  assert reference["SORT"].to_s == res
end

test "UNSUBSCRIBE" do |reference|
  res = "UNSUBSCRIBE [channel1 channel2 ... channelN]"
  assert reference["UNSUBSCRIBE"].to_s == res
end

test "ZINTERSTORE" do |reference|
  res = "ZINTERSTORE destination key1 key2 ... keyN [WEIGHTS weight1 weight2" +
        " ... weightN] [AGGREGATE SUM|MIN|MAX]"
  assert reference["ZINTERSTORE"].to_s == res
end

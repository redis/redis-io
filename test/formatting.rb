require "./test/helper"

require File.expand_path("../lib/reference", File.dirname(__FILE__))

reference = Reference.new(JSON.parse(File.read("#{documentation_path}/commands.json")))

setup do
  reference
end

test "DEBUG OBJECT" do |reference|
  res = "DEBUG OBJECT key"
  assert_equal reference["DEBUG OBJECT"].to_s, res
end

test "DEL" do |reference|
  res = "DEL key1 key2 ... keyN"
  assert_equal reference["DEL"].to_s, res
end

test "DISCARD" do |reference|
  res = "DISCARD"
  assert_equal reference["DISCARD"].to_s, res
end

test "SORT" do |reference|
  res = "SORT key [BY pattern] [LIMIT offset count] [GET pattern1 GET pattern2" +
        " ... GET patternN] [ASC|DESC] [ALPHA] [STORE destination]"
  assert_equal reference["SORT"].to_s, res
end

test "UNSUBSCRIBE" do |reference|
  res = "UNSUBSCRIBE [channel1 channel2 ... channelN]"
  assert_equal reference["UNSUBSCRIBE"].to_s, res
end

test "ZINTERSTORE" do |reference|
  res = "ZINTERSTORE destination numkeys key1 key2 ... keyN [WEIGHTS weight1 weight2" +
        " ... weightN] [AGGREGATE SUM|MIN|MAX]"
  assert_equal reference["ZINTERSTORE"].to_s, res
end

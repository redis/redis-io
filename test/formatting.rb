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
  res = "DEL key [key ...]"
  assert_equal reference["DEL"].to_s, res
end

test "DISCARD" do |reference|
  res = "DISCARD"
  assert_equal reference["DISCARD"].to_s, res
end

test "SORT" do |reference|
  res = "SORT key [BY pattern] [LIMIT offset count] [GET pattern [GET pattern ...]]" +
        " [ASC|DESC] [ALPHA] [STORE destination]"
  assert_equal reference["SORT"].to_s, res
end

test "UNSUBSCRIBE" do |reference|
  res = "UNSUBSCRIBE [channel [channel ...]]"
  assert_equal reference["UNSUBSCRIBE"].to_s, res
end

test "ZINTERSTORE" do |reference|
  res = "ZINTERSTORE destination numkeys key [key ...] [WEIGHTS weight [weight ...]]" +
        " [AGGREGATE SUM|MIN|MAX]"
  assert_equal reference["ZINTERSTORE"].to_s, res
end

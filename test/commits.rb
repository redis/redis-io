require "./test/helper"
require "rack/test"

class Cutest::Scope
  include Rack::Test::Methods

  def app
    Cuba
  end
end

scope do
  setup do
    redis.flushdb
  end

  test "refreshes the latest commits" do
    post "/commits", payload: "{}"

    visit "/"

    assert has_css?("#commits li a")
  end
end

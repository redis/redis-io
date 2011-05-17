require "./test/helper"

scope do
  test do
    visit "/commands.json"

    assert has_content?("\"APPEND\": {")

    visit "/clients.json"

    assert has_content?("\"name\": \"redis-rb\"")
  end
end

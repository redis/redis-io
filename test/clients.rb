require "./test/helper"

scope do
  test "Clients page" do
    visit "/clients"

    assert has_css?("h2", text: "Ruby")
    assert has_content?("redis-rb")
  end
end

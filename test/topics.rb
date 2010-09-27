require "./test/helper"

scope do
  test "Topic" do
    visit "/topics/replication"

    assert has_xpath?("//title", text: "Replication")
    assert has_xpath?("//h1", text: "Replication")
    assert has_xpath?("//h2", text: "Configuration")
  end
end

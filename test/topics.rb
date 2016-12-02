require "./test/helper"

scope do
  test "Topic" do
    visit "/topics/replication"

    assert has_title?("Replication")
    assert has_xpath?("//h1", text: "Replication")
    assert has_xpath?("//h2", text: "Configuration")
  end

  test "Missing topic" do
    visit "/topics/foobar"

    assert has_content?("Sorry")
    assert has_content?("topics/foobar.md")
    assert page.driver.response.status == 404
  end
end

require "./test/helper"

scope do
  test "Sitemap" do
    visit "/"

    click "Download"

    assert has_content?("Redis is now compiled.")
  end
end

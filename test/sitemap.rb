require "./test/helper"

scope do
  test "Sitemap" do
    visit "/"

    click "Download"

    assert has_content?("Redis is now compiled.")

    click "Community"

    assert has_css?("a[href='http://groups.google.com/group/redis-db']", text: "mailing list")
    assert has_content?("#redis")
    assert has_css?("a[href='http://twitter.com/antirez']", text: "Salvatore")

    click "Documentation"

    click "full list of commands"

    assert has_content?("PING")
  end
end

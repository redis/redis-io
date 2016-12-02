require "./test/helper"

scope do
  test "Command reference" do
    visit "/commands"

    assert has_content?("ECHO")
    assert has_content?("Echo the given string")
  end

  test "Command page" do
    visit "/commands"

    click_link_or_button "ECHO"

    assert has_title?("ECHO")

    within "h1" do
      assert has_content?("ECHO")
      assert has_content?("message")
    end

    within "article" do
      assert has_css?("p", text: "Returns message.")
      assert has_content?("Available since 1.0.0")
    end
  end

  test "Command page with complex arguments" do
    visit "/commands"

    click_link_or_button "SORT"

    within "h1" do
      assert has_content?("[BY pattern]")
      assert has_content?("[LIMIT offset count]")
      assert has_content?("[ASC|DESC]")
      assert has_content?("[ALPHA]")
      assert has_content?("[STORE destination]")
    end
  end

  test "Commands with spaces" do
    visit "/commands"

    click_link_or_button "DEBUG OBJECT"

    assert has_title?("DEBUG OBJECT")
    assert has_css?("h1", text: "DEBUG OBJECT")
  end

  test "Missing command" do
    visit "/commands/foobar"

    assert_equal page.current_url, "https://www.google.com/search?q=foobar+site%3Aredis.io"
  end
end

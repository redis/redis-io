require "./test/helper"

scope do
  test "Command reference" do
    visit "/commands"

    assert has_content?("ECHO")
    assert has_content?("Echo the given string")
  end

  test "Command page" do
    visit "/commands"

    click_link_or_button "EXPIREAT"

    assert has_css?("title", text: "EXPIREAT")

    within "h1" do
      assert has_content?("EXPIREAT")
      assert has_content?("key")
      assert has_content?("timestamp")
    end

    within "article" do
      assert has_css?("p", text: "Set a timeout on key.")
      assert has_content?("Available since 1.1")
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

    assert has_css?("title", text: "DEBUG OBJECT")
    assert has_css?("h1", text: "DEBUG OBJECT")
  end
end

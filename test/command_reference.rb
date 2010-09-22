require "cuba/test"
require File.expand_path("../app", File.dirname(__FILE__))

begin
  require "ruby-debug"
rescue LoadError
end

Capybara.default_selector = :css

scope do
  test "Command reference" do
    visit "/commands"

    assert has_content?("ECHO")
  end

  test "Command page" do
    visit "/commands"

    click "SELECT"

    assert has_css?("title", text: "SELECT")

    within "h1" do
      assert has_content?("SELECT")
      assert has_content?("index")
    end

    within "article" do
      assert has_css?("p", text: "Select the DB")
    end
  end

  test "Command page with complex arguments" do
    visit "/commands"

    click "SORT"

    within "h1" do
      by = find(".argument", text: "by")

      assert by
      assert by.node.at_css("span.command").text["by"]
      assert by.text["pattern"]

      limit = find(".argument", text: "limit")

      assert limit
      assert limit.node.at_css("span.command").text["limit"]
      assert limit.text["start, count"]

      order = find(".argument", text: "asc")

      assert order
      assert !order.node.at_css("span.command")
      assert order.text["asc|desc"]

      alpha = find(".argument", text: "alpha")

      assert alpha
      assert !alpha.node.at_css("span.command")
      assert alpha.text["alpha"]

      store = find(".argument", text: "store")

      assert store
      assert store.node.at_css("span.command").text["store"]
      assert store.text["destination"]
    end
  end
end

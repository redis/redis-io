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
      by = find(".argument", text: "BY")

      assert by
      assert by.node.at_css("span.command").text["BY"]
      assert by.text["pattern"]

      limit = find(".argument", text: "LIMIT")

      assert limit
      assert limit.node.at_css("span.command").text["LIMIT"]
      assert limit.text["start, count"]

      order = find(".argument", text: "ASC")

      assert order
      assert !order.node.at_css("span.command")
      assert order.text["ASC|DESC"]

      alpha = find(".argument", text: "ALPHA")

      assert alpha
      assert !alpha.node.at_css("span.command")
      assert alpha.text["ALPHA"]

      store = find(".argument", text: "STORE")

      assert store
      assert store.node.at_css("span.command").text["STORE"]
      assert store.text["destination"]
    end
  end
end

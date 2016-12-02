require "cuba/capybara"
require File.expand_path("../app", File.dirname(__FILE__))

begin
  require "ruby-debug"
rescue LoadError
end

Capybara.default_selector = :css

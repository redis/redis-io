require "cuba"
require "haml"
require "rdiscount"
require "json"

Cuba.define do
  on get, path("commands") do
    on segment do |name|
      @command = JSON.parse(File.read("tmp/redis-doc/commands.json"))[name]
      @name = name
      @body = render("tmp/redis-doc/commands/#{name}.md")

      res.write render("views/commands/name.haml")
    end

    on default do
      @commands = JSON.parse(File.read("tmp/redis-doc/commands.json"))

      res.write render("views/commands.haml")
    end
  end
end

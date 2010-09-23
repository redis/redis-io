require "cuba"
require "haml"
require "rdiscount"
require "json"

Cuba.define do
  def haml(template, locals = {})
    render("views/layout.haml", content: render("views/#{template}.haml", locals))
  end

  on get, path("commands") do
    on segment do |name|
      @name = name.upcase
      @command = JSON.parse(File.read("redis-doc/commands.json"))[@name]
      @body = render("redis-doc/commands/#{name}.md")
      @title = @name

      res.write haml("commands/name")
    end

    on default do
      @commands = JSON.parse(File.read("redis-doc/commands.json"))
      @title = "Command reference"

      res.write haml("commands")
    end
  end
end

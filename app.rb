require "cuba"
require "haml"
require "rdiscount"
require "json"

class RedisTemplate < Tilt::RDiscountTemplate
  SECTIONS = {
    "complexity"  => "Time complexity",
    "description" => "Description",
    "examples"    => "Examples",
    "return"      => "Return value",
  }

  def preprocess(source)
    source.gsub(/^\@(\w+)$/) do
      title = SECTIONS[$1]
      "#{title}\n---"
    end
  end

  def prepare
    @data = preprocess(@data)
    super
  end
end

Tilt.register "md", RedisTemplate

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

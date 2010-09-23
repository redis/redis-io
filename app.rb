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

  REPLY_TYPES = {
    "status"      => "Status code reply",
    "integer"     => "Integer reply",
    "bulk"        => "Bulk reply",
    "multi-bulk"  => "Multi-bulk reply"
  }

  def sections(source)
    source.gsub(/^\@(\w+)$/) do
      title = SECTIONS[$1]
      "#{title}\n---"
    end
  end

  def autolink_commands(source)
    source.gsub(/\B`([A-Z]+)`\B/) do
      name = $1
      command = commands[name]

      if command
        "[#{name}](/commands/#{name.downcase})"
      else
        name
      end
    end
  end

  def reply_types(source)
    source.gsub(/@(#{REPLY_TYPES.keys.join("|")})\-reply/) do
      type = $1
      "[#{REPLY_TYPES[type]}](/protocol##{type}-reply)"
    end
  end

  def preprocess(data)
    data = sections(data)
    data = autolink_commands(data)
    data = reply_types(data)
    data
  end

  def prepare
    @data = preprocess(@data)
    super
  end
end

Tilt.register "md", RedisTemplate

def commands
  $commands ||= JSON.parse(File.read("redis-doc/commands.json"))
end

Cuba.define do
  def haml(template, locals = {})
    render("views/layout.haml", content: render("views/#{template}.haml", locals))
  end

  on get, path("commands") do
    on segment do |name|
      @name = name.upcase
      @command = commands[@name]
      @body = render("redis-doc/commands/#{name}.md")
      @title = @name

      res.write haml("commands/name")
    end

    on default do
      @commands = commands
      @title = "Command reference"

      res.write haml("commands")
    end
  end
end

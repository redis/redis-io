require "tilt/redcarpet"

class RedisTemplate < Tilt::Redcarpet2Template
  SECTIONS = {
    "description" => "Description",
    "examples"    => "Examples",
    "return"      => "Return value",
    "history"     => "History"
  }

  REPLY_TYPES = {
    "nil"           => "Null reply",
    "simple-string" => "Simple string reply",
    "integer"       => "Integer reply",
    "bulk-string"   => "Bulk string reply",
    "array"         => "Array reply"
  }

  def sections(source)
    source.gsub(/^\@(\w+)$/) do
      title = SECTIONS[$1]
      "## #{title}\n"
    end
  end

  # Prefix commands that should *not* be autolinked with "!".
  def autolink_commands(source)
    source.gsub(/\B`(!?[A-Z\- ]+)`\B/) do
      name = $1
      command = commands[name]

      if command
        "[#{name}](/commands/#{name.downcase.gsub(' ', '-')})"
      else
        name.gsub!(/^!/, "")
        "`#{name}`"
      end
    end
  end

  def reply_types(source)
    source.gsub(/@(#{REPLY_TYPES.keys.join("|")})\-reply/) do
      type = $1
      "[#{REPLY_TYPES[type]}](/topics/protocol##{type}-reply)"
    end
  end

  def formulas(source)
    source.gsub(/(O\(.+?\)[\+\s\.,])/) do
      %Q[<span class="math">#{$1}</span>]
    end
  end

  def erb(data)
    ERB.new(data).result(binding)
  end

  def preprocess(data)
    data = erb(data)
    data = sections(data)
    data = autolink_commands(data)
    data = reply_types(data)
    data = formulas(data)
    data
  end

  def prepare
    @data = preprocess(@data)
    super
  end
end

Tilt.register "md", RedisTemplate

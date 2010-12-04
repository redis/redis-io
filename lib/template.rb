class Tilt::SassTemplate
  OPTIONS = Compass.sass_engine_options
  OPTIONS.merge!(style: :compact, line_comments: false)
  OPTIONS[:load_paths] << File.expand_path("views")

  def prepare
    @engine = ::Sass::Engine.new(data, sass_options.merge(OPTIONS))
  end
end

class RedisTemplate < Tilt::RDiscountTemplate
  SECTIONS = {
    "complexity"  => "Time complexity",
    "description" => "Description",
    "examples"    => "Examples",
    "return"      => "Return value",
  }

  REPLY_TYPES = {
    "nil"         => "Null multi-bulk reply",
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

  # Prefix commands that should *not* be autolinked with "!".
  def autolink_commands(source)
    source.gsub(/\B`(!?[A-Z]+)`\B/) do
      name = $1
      command = commands[name]

      if command
        "[#{name}](/commands/#{name.downcase})"
      else
        name.gsub!(/^!/, "")
        "`#{name}`"
      end
    end
  end

  def reply_types(source)
    source.gsub(/@(#{REPLY_TYPES.keys.join("|")})\-reply/) do
      type = $1
      "[#{REPLY_TYPES[type]}](/protocol##{type}-reply)"
    end
  end

  def formulas(source)
    source.gsub(/(O\(.+?\)[\+\s\.,])/) do
      %Q[<span class="math">#{$1}</span>]
    end
  end

  def preprocess(data)
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

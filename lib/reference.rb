class Reference
  GROUPS = {
    "generic" => "Keys",
    "string" => "Strings",
    "hash" => "Hashes",
    "list" => "Lists",
    "set" => "Sets",
    "sorted_set" => "Sorted Sets",
    "hyperloglog" => "HyperLogLog",
    "pubsub" => "Pub/Sub",
    "transactions" => "Transactions",
    "scripting" => "Scripting",
    "connection" => "Connection",
    "server" => "Server",
    "cluster" => "Cluster",
    "geo" => "Geo",
    "stream" => "Streams",
    "bitmap" => "Bitmaps",
    "cluster" => "Cluster",
    "sentinel" => "Sentinel"
  }

  class Command
    class Argument
      attr :argument

      def initialize(argument)
        @argument = argument
      end

      def type
        argument["type"]
      end

      def optional?
        argument["optional"] || false
      end

      def multiple?
        argument["multiple"] || false
      end

      def multiple_token?
        argument["multiple_token"] || false
      end

      def to_s
        if type == "block"
          res = block(argument)
        elsif type == "oneof"
          res = oneof(argument)
        elsif type != "pure-token"
          res = argument["name"]
        else
          res = ""
        end

        token = argument["token"]
        if token == ""
          token = "\"\""
        end
        if multiple_token?
          res = "#{res} [#{token} #{res} ...]"
        elsif multiple?
          res = "#{res} [#{res} ...]"
        end

        if token
          res = "#{token} #{res}"
          res = res.strip! || res
        end

        optional? ? "[#{res}]" : res
      end

    private

      def block(argument)
        argument["arguments"].map do |entry|
          Argument.new(entry)
        end.join(" ")
      end

      def oneof(argument)
        argument["arguments"].map do |entry|
          Argument.new(entry)
        end.join("|")
      end
    end

    attr :name
    attr :command
    attr :group

    def initialize(name, command)
      @name = name
      @command = command
    end

    def to_s
      @to_s ||= [name, *arguments].join(" ")
    end

    def since
      command["since"]
    end

    def group
      command["group"]
    end

    def complexity
      command["complexity"]
    end

    def deprecated_since
      command["deprecated_since"]
    end

    def replaced_by
      command["replaced_by"]
    end

    def history
      command["history"]
    end

    def is_helpsubcommand?
      name.downcase.end_with?(" help")
    end

    def is_purecontainer?
      command["arity"] == -2 && !command["arguments"]
    end

    def is_listed?
      !is_purecontainer? && !is_helpsubcommand?
    end

    def to_param
      name.downcase.gsub(" ", "-")
    end

    def arguments
      (command["arguments"] || []).map do |argument|
        Argument.new(argument)
      end
    end

    include Comparable

    def ==(other)
      name == other.name
    end
    alias eql? ==

    def hash
      name.hash
    end
  end

  include Enumerable

  def initialize(commands)
    @commands = commands
  end

  def [](name)
    Command.new(name, @commands[name]) if @commands[name]
  end

  def each
    @commands.each do |name, attrs|
      yield Command.new(name, attrs)
    end
  end

  def sample
    key = @commands.keys.sample

    Command.new(key, @commands[key])
  end
end

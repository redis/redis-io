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
  }

  class Command
    class Argument
      attr :argument

      def initialize(argument)
        @argument = argument
      end

      def type
        [argument["type"]].flatten
      end

      def optional?
        argument["optional"] || false
      end

      def multiple?
        argument["multiple"] || false
      end

      def to_s
        if argument["multiple"]
          res = multiple(argument)
        elsif argument["variadic"]
          res = variadic(argument)
        elsif argument["enum"]
          res = enum(argument)
        else
          res = simple(argument)
        end

        argument["optional"] ? "[#{res}]" : res
      end

    private

      def multiple(argument)
        complex(argument) do |part|
          part.unshift(argument["command"]) if argument["command"]
        end
      end

      def variadic(argument)
        [argument["command"], complex(argument)].join(" ")
      end

      def complex(argument)
        2.times.map do |i|
          part = Array(argument["name"])
          yield(part) if block_given?
          part = part.join(" ")
          i == 0 ? part : "[" + part + " ...]"
        end.join(" ")
      end

      def simple(argument)
        [argument["command"], argument["name"]].compact.flatten.join(" ")
      end

      def enum(argument)
        [argument["command"], argument["enum"].join("|")].compact.join(" ")
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

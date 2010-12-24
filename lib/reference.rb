class Reference
  GROUPS = {
    "generic" => "Keys",
    "string" => "Strings",
    "hash" => "Hashes",
    "list" => "Lists",
    "set" => "Sets",
    "sorted_set" => "Sorted Sets",
    "pubsub" => "Pub/Sub",
    "transactions" => "Transactions",
    "connection" => "Connection",
    "server" => "Server",
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
        complex(argument) do |parts|
          parts.collect! do |part|
            part.unshift(argument["command"])
          end
        end
      end

      def variadic(argument)
        complex(argument) do |parts|
          parts.unshift(argument["command"])
        end
      end

      def complex(argument)
        parts = %w{1 2 N}.map do |suffix|
          Array(argument["name"]).map do |arg|
            "#{arg}#{suffix}"
          end
        end

        yield(parts) if argument["command"]

        parts.insert(-2, "...").flatten.join(" ")
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
end

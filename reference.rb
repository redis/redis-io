class Reference
  class Command
    class Argument
      attr :argument

      def initialize(argument)
        @argument = argument
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

    def initialize(name, command)
      @name = name
      @command = command
    end

    def to_s
      @to_s ||= [name].tap do |res|
        break res unless command["arguments"]

        command["arguments"].each do |argument|
          res << Argument.new(argument).to_s
        end
      end.join(" ")
    end

    def since
      command["since"]
    end
  end

  def initialize(commands)
    @commands = commands
  end

  def [](name)
    Command.new(name, @commands[name])
  end

  def each
    @commands.each do |name, attrs|
      yield Command.new(name, attrs)
    end
  end
end

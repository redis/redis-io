require File.expand_path(File.dirname(__FILE__) + "/redis")

module Interactive

  UNESCAPES = {
    'a' => "\x07", 'b' => "\x08", 't' => "\x09",
    'n' => "\x0a", 'v' => "\x0b", 'f' => "\x0c",
    'r' => "\x0d", 'e' => "\x1b", "\\\\" => "\x5c",
    "\"" => "\x22", "'" => "\x27"
  }

  # Create and find actions have race conditions, but I don't
  # really care about them right now...
  class Session

    TIMEOUT = 3600

    # Create new instance.
    def self.create(namespace)
      raise "Already exists" if redis.zscore("sessions", namespace)
      touch(namespace)
      new(namespace)
    end

    # Return instance if namespace exists in sorted set.
    def self.find(namespace)
      if timestamp = redis.zscore("sessions", namespace)
        if Time.now.to_i - timestamp.to_i < TIMEOUT
          touch(namespace)
          new(namespace)
        end
      end
    end

    # Try to clean up old sessions
    def self.clean!
      now = Time.now.to_i
      threshold = now - TIMEOUT
      namespace, timestamp = redis.zrangebyscore("sessions", "-inf", threshold,
        :with_scores => true, :limit => [0, 1])
      return if namespace.nil?

      if redis.zrem("sessions", namespace)
        keys = redis.smembers("session:#{namespace}:keys")
        redis.del(*keys.map { |key| "#{namespace}:#{key}" }) if !keys.empty?
        redis.del("session:#{namespace}:keys")
        redis.del("session:#{namespace}:commands")
      end
    end

    # This should only be created through #new or #create
    private_class_method :new

    attr :namespace

    def initialize(namespace)
      @namespace = namespace
      self.class.clean!
    end

    def run(line)
      _run(line)
    rescue => error
      format_reply(ErrorReply.new("ERR " + error.message))
    end

  private

    def self.touch(namespace)
      redis.zadd("sessions", Time.now.to_i, namespace)
    end

    def register(arguments)
      # TODO: Only store keys that receive writes.
      keys = ::Interactive.keys(arguments)
      redis.pipelined do
        keys.each do |key|
          redis.sadd("session:#{namespace}:keys", key)
        end
      end

      # Command counter, not yet used
      redis.incr("session:#{namespace}:commands")
    end

    def unescape_literal(str)
      # Escape all the things
      str.gsub(/\\(?:([#{UNESCAPES.keys.join}])|u([\da-fA-F]{4}))|\\0?x([\da-fA-F]{2})/) {
        if $1
          if $1 == '\\' then '\\' else UNESCAPES[$1] end
        elsif $2 # escape \u0000 unicode
          ["#$2".hex].pack('U*')
        elsif $3 # escape \0xff or \xff
          [$3].pack('H2')
        end
      }
    end

    # Parse a command line style list of arguments that can be optionally
    # delimited by '' or "" quotes, and return it as an array of arguments.
    #
    # Strings delimited by "" are unescaped by converting escape characters
    # such as \n \x.. to their value according to the unescape_literal()
    # function.
    #
    # Example of line that this function can parse:
    #
    # "Hello World\n" other arguments 'this is a single argument'
    #
    # The above example will return an array of four strings.
    def cli_split(line)
      argv = []
      arg = ""
      inquotes = false
      pos = 0
      while pos < line.length
        char = line[pos..pos] # Current character
        isspace = char =~ /\s/

        # Skip empty spaces if we are between strings
        if !inquotes && isspace
          if arg.length != 0
            argv << arg
            arg = ""
          end
          pos += 1
          next
        end

         # Append current char to string
         arg << char
         pos += 1

         if arg.length == 1 && (char == '"' || char == '\'')
           inquotes = char
         elsif arg.length > 1 && inquotes && char == inquotes
           inquotes = false
         end
      end
      # Put the last argument into the array
      argv << arg if arg.length != 0

      # We need to make some post-processing.
      # For strings delimited by '' we just strip initial and final '.
      # For strings delimited by "" we call unescape_literal().
      # This is not perfect but should be enough for redis.io interactive
      # editing.
      argv.map {|x|
        if x[0..0] == '"'
          unescape_literal(x[1..-2])
        elsif x[0..0] == '\''
          x[1..-2]
        else
          x
        end
      }
    end

    def _run(line)
      begin
        arguments = cli_split(line)
      rescue => error
        raise error.message.split(":").first
      end

      if arguments.empty?
        raise "No command"
      end

      if arguments.size > 100 || arguments.any? { |arg| arg.size > 100 }
        raise "Web-based interface is limited"
      end

      case arguments[0].downcase
      when "setbit"
        if arguments[2].to_i >= 2048
          raise "Web-based interface is limited"
        end
      when "setrange"
        if arguments[2].to_i + arguments[3].to_s.size >= 256
          raise "Web-based interface is limited"
        end
      end

      namespaced = ::Interactive.namespace(namespace, arguments)
      if namespaced.empty?
        raise "Unknown or disabled command '%s'" % arguments.first
      end

      # Register the call
      register(arguments)

      # Make the call
      reply = ::Interactive.redis.call(*namespaced)

      case arguments.first.downcase
      when "keys"
        # Strip namespace for KEYS
        if reply.respond_to?(:map)
          format_reply(reply.map { |key| key[/^\w+:(.*)$/,1] })
        else
          format_reply(reply)
        end
      when "info"
        # Don't #inspect the string reply for INFO
        reply.to_s
      else
        format_reply(reply)
      end
    end

    def format_reply(reply, prefix = "")
      case reply
      when LineReply
        reply.to_s + "\n"
      when Integer
        "(integer) " + reply.to_s + "\n"
      when String
        reply.inspect + "\n"
      when NilClass
        "(nil)\n"
      when Array
        if reply.empty?
          "(empty list or set)\n"
        else
          out = ""
          index_size = reply.size.to_s.size
          reply.each_with_index do |element, index|
            out << prefix if index > 0
            out << "%#{index_size}d) " % (index + 1)
            out << format_reply(element, prefix + (" " * (index_size + 2)))
          end
          out
        end
      else
        raise "Don't know how to format #{reply.inspect}"
      end
    end
  end
end


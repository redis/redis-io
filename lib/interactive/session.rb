require "shellwords"

module Interactive

  class LineReply < String; end
  class StatusReply < LineReply; end
  class ErrorReply < LineReply; end

  module RedisHacks

    def format_status_reply(line)
      StatusReply.new(line.strip)
    end

    def format_error_reply(line)
      ErrorReply.new(line.strip)
    end
  end

  class Session

    attr :namespace

    def self.redis
      @redis ||=
        begin
          redis = new_redis_connection
          class << redis.client
            include RedisHacks
          end
          redis
        end
    end

    def initialize(namespace)
      @namespace = namespace
    end

    def run(line)
      _run(line)
    rescue => error
      format_reply(ErrorReply.new("ERR " + error.message))
    end

  private

    def _run(line)
      begin
        arguments = Shellwords.shellwords(line)
      rescue => error
        raise error.message.split(":").first
      end

      if arguments.empty?
        raise "No command"
      end

      if arguments.size > 100 || arguments.any? { |arg| arg.size > 100 }
        raise "Web-based interface is limited"
      end

      namespaced = ::Interactive.namespace(namespace, arguments)
      if namespaced.empty?
        raise "Unknown or disabled command '%s'" % arguments.first
      end

      # Make the call
      reply = self.class.redis.client.call(*namespaced)

      # Strip namespace for KEYS
      if arguments.first.downcase == "keys"
        reply.map! { |key| key[/^\w+:(.*)$/,1] }
      end

      format_reply(reply)
    end

    def format_reply(reply, prefix = "")
      case reply
      when LineReply
        reply.to_s + "\n"
      when Fixnum
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


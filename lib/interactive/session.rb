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
      arguments = Shellwords.shellwords(line)
      if arguments.empty?
        reply = ErrorReply.new("ERR No command")
      else
        with_namespace = ::Interactive.namespace(namespace, arguments.dup)
        if with_namespace.nil?
          reply = ErrorReply.new("ERR Unknown or disabled command '%s'" % arguments[0])
        else
          reply = self.class.redis.client.call(*with_namespace)
        end
      end
      format_reply(reply)
    end

  private

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


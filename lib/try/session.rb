module Try

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

    def run(args)
      with_namespace = try_commands.namespace(namespace, args)
      reply = self.class.redis.client.call(*with_namespace)
      format_reply(reply)
    end

  private

    def format_reply(reply, prefix = "")
      case reply
      when LineReply, Fixnum
        reply.to_s + "\n"
      when String
        reply.inspect + "\n"
      when NilClass
        "(nil)\n"
      when Array
        out = ""
        index_size = reply.size.to_s.size
        reply.each_with_index do |element, index|
          out << prefix if index > 0
          out << "%#{index_size}d) " % (index + 1)
          out << format_reply(element, prefix + (" " * (index_size + 2)))
        end
        out
      else
        raise "Don't know how to format #{reply.inspect}"
      end
    end
  end
end


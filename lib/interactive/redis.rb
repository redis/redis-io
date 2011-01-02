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

  def self.redis
    @redis ||=
      begin
        redis = new_redis_connection
        class << redis.client.connection
          include RedisHacks
        end
        redis
      end
  end
end


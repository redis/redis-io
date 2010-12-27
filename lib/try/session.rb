module Try

  class Session

    attr :namespace

    def initialize(namespace)
      @namespace = namespace
    end

    def run(args)
      with_namespace = try_commands.namespace(namespace, args)
      response = redis.client.call(*with_namespace)
      response.inspect
    end
  end
end


module Try

  # Explicitly allow certain groups (don't allow "server",
  # "connection" and "pubsub" commands by default).
  ALLOW_GROUPS = %w(generic hash list set sorted_set string transactions).freeze

  # Override ALLOW_GROUPS for some commands.
  ALLOW_COMMANDS = %w(ping select echo dbsize info lastsave).freeze

  # Explicitly deny some commands.
  DENY_COMMANDS = %w(blpop brpop brpoplpush).freeze

  class Commands

    attr :commands
    attr :patterns

    def initialize(commands)
      @commands = commands.select { |cmd| allow?(cmd) }
      @patterns = Hash[*@commands.map do |cmd|
        args = cmd.arguments
        if args.empty?
          pattern = []
        elsif args.all? { |arg| !arg.multiple? && !arg.optional? && arg.type.size == 1 }
          # Constant number of arguments can be zipped
          pattern = [:zip, args.map { |arg| arg.type == ["key"] } ]
        elsif args.size == 1 && args[0].multiple? && args[0].type.include?("key")
          # Single variadic argument with key can be zipped
          pattern = [:zip, args[0].type.map { |type| type == "key" } ]
        elsif args[0].type == ["key"] && !args[0].multiple? &&
            args[1..-1].none? { |arg| arg.type.include?("key") }
          # Only namespace the first argument
          pattern = [:first]
        elsif args.all? { |arg| arg.type == ["key"] }
          # Namespace all arguments
          pattern = [:all]
        else
          # Non-standard
          pattern = [:custom]
        end

        [cmd.name.downcase, pattern]
      end.compact.flatten(1)]
    end

    def namespace(ns, args)
      name = args.shift
      return if patterns[name.downcase].nil?
      type, pattern = patterns[name.downcase]

      case type
      when :first
        if !args.empty?
          args[0] = namespace_key(ns, args[0])
        end
      when :all
        args.map! { |arg| namespace_key(ns, arg) }
      when :zip
        # Zip args with cycling pattern (for arguments of type multiple)
        args = args.zip(pattern.cycle).map do |arg, apply|
          apply ? namespace_key(ns, arg) : arg
        end
      when :custom
        case name.downcase
        when "zunionstore", "zinterstore"
          # Destination key
          if args.size >= 1
            args[0] = namespace_key(ns, args[0])

            # Number of input keys
            if args.size >= 3
              numkeys = args[1].to_i
              args[2,numkeys] = args[2,numkeys].map do |arg|
                namespace_key(ns, arg)
              end
            end
          end
        when "sort"
          tmpargs = args.dup
          args = []

          # Key to sort
          if !tmpargs.empty?
            args << namespace_key(ns, tmpargs.shift)

            while keyword = tmpargs.shift
              args << keyword
              if !tmpargs.empty?
                case keyword.downcase
                when "get"
                  what = tmpargs.shift
                  if what == "#"
                    args << what
                  else
                    args << namespace_key(ns, what)
                  end
                when "by", "store"
                  args << namespace_key(ns, tmpargs.shift)
                when "limit"
                  break if tmpargs.size < 2
                  2.times { args << tmpargs.shift }
                end
              end
            end
          end
        else
          raise "Don't know what to do for \"#{name.downcase}\""
        end
      end

      [name, *args]
    end

  private

    def namespace_key(ns, key)
      [ns, key].join(":")
    end

    def allow?(cmd)
      !DENY_COMMANDS.include?(cmd.name.downcase) &&
        (ALLOW_COMMANDS.include?(cmd.name.downcase) ||
         ALLOW_GROUPS.include?(cmd.group))
    end
  end
end


require File.expand_path(File.dirname(__FILE__) + "/commands")

module Interactive

  def self.namespace(ns, args)
    pattern(args).map do |arg,type|
      if type == :key || type == :ns
        [ns, arg].join(":")
      else
        arg
      end
    end
  end

  def self.keys(args)
    pattern(args).map do |arg,type|
      arg if type == :key
    end.compact
  end

  def self.pattern(args)
    args = args.dup
    name = args.shift
    return [] if COMMANDS[name.downcase].nil?
    type, pattern = COMMANDS[name.downcase]
    out = []

    case type
    when :first
      out[0] = :key
    when :all
      out = args.size.times.map { :key }
    when :zip
      out = args.zip(pattern.cycle).map do |arg, type|
        :key if type == :key
      end
    when :custom
      case name.downcase
      when "info", "geoencode", "ping"
        # Commands without keys
        nil
      when "bitop"
        # BITOP arg positions 1,2,3 are always keys
        out[1,3] = 3.times.map{:key}
      when "zunionstore", "zinterstore"
        # Destination key
        if args.size >= 1
          out[0] = :key

          # Number of input keys
          if args.size >= 3
            numkeys = args[1].to_i
            out[2,numkeys] = numkeys.times.map { :key }
          end
        end
      when "sort"
        tmpargs = args.dup

        # Key to sort
        if !tmpargs.empty?
          tmpargs.shift
          out << :key

          while keyword = tmpargs.shift
            out << nil
            if !tmpargs.empty?
              case keyword.downcase
              when "get"
                if tmpargs.shift == "#"
                  out << nil
                else
                  out << :key
                end
              when "by", "store"
                tmpargs.shift
                out << :key
              when "limit"
                break if tmpargs.size < 2
                2.times { tmpargs.shift; out << nil }
              end
            end
          end
        end
      when "georadius","georadiusbymember"
        tmpargs = args.dup

        # First key with the sorted set
        if !tmpargs.empty?
          tmpargs.shift
          out << :key

          while keyword = tmpargs.shift
            out << nil
            if !tmpargs.empty?
              case keyword.downcase
              when "store", "storedist"
                tmpargs.shift
                out << :key
              end
            end
          end
        end
      else
        raise "Don't know what to do for \"#{name.downcase}\""
      end
    end

    # Hack KEYS command
    if name.downcase == "keys"
      out[0] = :ns
    end

    out = args.zip(out).to_a
    [[name, []], *out]
  end
end


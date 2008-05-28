$:.unshift File.dirname(__FILE__)

module Polyglot
  @registrations ||= {} # Guard against reloading
  @loaded ||= {}

  def self.register(extension, klass)
    extension = [extension] unless Enumerable === extension
    extension.each{|e|
      @registrations[e] = klass
    }
  end

  def self.find(file, *options, &block)
    extensions = @registrations.keys*","
    is_absolute = file[0] == File::SEPARATOR || file[0] == File::ALT_SEPARATOR || file =~ /\A[A-Z]:\\/i
    (is_absolute ? [""] : $:).each{|lib|
      base = is_absolute ? "" : lib+File::SEPARATOR
      # In Windows, repeated SEPARATOR chars have a special meaning, avoid adding them
      matches = Dir[base+file+".{"+extensions+"}"]
      # Revisit: Should we do more do if more than one candidate found?
      $stderr.puts "Polyglot: found more than one candidate for #{file}: #{matches*", "}" if matches.size > 1
      if path = matches[0]
        return [ path, @registrations[path.gsub(/.*\./,'')]]
      end
    }
    return nil
  end

  def self.load(*a, &b)
    return if @loaded[a[0]] # Check for $: changes or file time changes and reload?
    begin
      source_file, loader = Polyglot.find(*a, &b)
      if (loader)
        loader.load(source_file)
        @loaded[a[0]] = true
      else
        msg = "Failed to load #{a[0]} using extensions #{(@registrations.keys+["rb"]).sort*", "}"
        if defined?(MissingSourceFile)
          raise MissingSourceFile.new(msg, a[0])
        else
          raise LoadError.new(msg)
        end
      end
    end
  end
end

module Kernel
  alias polyglot_original_require require

  def require(*a, &b)
    polyglot_original_require(*a, &b)
  rescue LoadError => load_error
    Polyglot.load(*a, &b)
  end
end

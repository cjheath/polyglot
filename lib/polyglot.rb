$:.unshift File.dirname(__FILE__)

module Polyglot
  @registrations ||= {}	# Guard against reloading
  @loaded ||= {}

  def self.register(extension, klass)
    extension = [extension] unless Enumerable === extension
    extension.each{|e|
      @registrations[e] = klass
    }
  end

  def self.find(file, *options, &block)
    extensions = @registrations.keys*","
    $:.each{|lib|
      matches = Dir[lib+"/"+file+".{"+extensions+"}"]
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
	raise load_error
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

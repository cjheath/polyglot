$:.unshift File.dirname(__FILE__)

module Polyglot
  @registrations ||= {}	# Guard against reloading

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
end

module Kernel
  alias polyglot_original_require require

  def require(*a, &b)
    polyglot_original_require(*a, &b)
  rescue LoadError => load_error
    begin
      source_file, loader = Polyglot.find(*a, &b)
      if (loader)
	loader.load(source_file)
      else
	raise load_error
      end
    end
  end
end

Ruby Gem:   Polyglot 0.1.0
Author:	    Clifford Heath, 2007

The Polyglot library allows a Ruby module to register a loader
for the file type associated with a filename extension, and it
augments 'require' to find and load matching files.

This supports the creation of DSLs having a syntax that is most
appropriate to their purpose, instead of abusing the Ruby syntax.

Files are sought using the normal Ruby search path.

Example:

In file rubyglot.rb, define and register a file type handler:

    require 'polyglot'

    class RubyglotLoader
      def self.load(filename, options = nil, &block)
	File.open(filename) {|file|
	  # Load the contents of file as Ruby code:
	  # Implement your parser here instead!
	  Kernel.eval(file.read)
	}
      end
    end

    Polyglot.register("rgl", RubyglotLoader)

In file test.rb:

    require 'rubyglot'	# Create my file type handler
    require 'hello'	# Can add extra options or even a block here
    puts "Ready to go"
    Hello.new

In file hello.rgl (this simple example uses Ruby code):

    puts "Initializing"
    class Hello
      def initialize()
	puts "Hello, world\n"
      end
    end

Run:

    $ ruby test.rb
    Initializing
    Ready to go
    Hello, world
    $

require 'rubygems'
require 'rake'
require 'jeweler'
require './lib/polyglot/version'

Jeweler::Tasks.new do |gem|
  gem.name = "polyglot"
  gem.version = Polyglot::VERSION::STRING
  gem.homepage = "http://github.com/cjheath/polyglot"
  gem.license = "MIT"
  gem.summary = %Q{Augment 'require' to load non-Ruby file types}
  gem.description = %Q{
The Polyglot library allows a Ruby module to register a loader
for the file type associated with a filename extension, and it
augments 'require' to find and load matching files.}
  gem.email = %w[clifford.heath@gmail.com]
  gem.authors = ["Clifford Heath"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "polyglot #{Polyglot::VERSION::STRING}"
  rdoc.rdoc_files.include('README.txt')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Generate website files'
task :website_generate do
  sh %q{ruby script/txt2html website/index.txt > website/index.html}
end

desc 'Upload website files via rsync'
task :website_upload do
  local_dir  = 'website'
  website_config = YAML.load(File.read("config/website.yml"))
  host       = website_config["host"]
  host       = host ? "#{host}:" : ""
  remote_dir = website_config["remote_dir"]
  sh %{rsync -aCv #{local_dir}/ #{host}#{remote_dir}}
end


require 'rubygems'
require 'bundler'
#safasf
begin
  Bundler.setup(:default, :development,:test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "linqr"
  gem.homepage = "http://github.com/suryagaddipati/linqr"
  gem.license = "MIT"
  gem.summary = %Q{Query Comprehensions for ruby}
  gem.description = %Q{Linq like sytax for querying multiple-datasources}
  gem.email = "surya.gaddipati@gmail.com"
  gem.authors = ["surya"]
end

Jeweler::RubygemsDotOrgTasks.new
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = ["./spec/**/*_spec.rb","./examples/**/*_spec.rb"] 
end
     
desc "Generate code coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.pattern = ["./spec/**/*_spec.rb","./examples/**/*_spec.rb"] 
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end


require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "linqr #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :generate_wiki do 
  load "wiki_generator.rb"
  Dir.glob("examples/*/**").each {|f| write_wiki(f)}
  ` cd  linqr.wiki`
end

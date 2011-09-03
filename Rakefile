
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

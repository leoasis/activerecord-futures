require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Runs the specs with all databases"
task :all do
  success = true
  ["mysql", "postgresql"].each do |adapter|
    status = system({ "ADAPTER" => adapter }, "bundle exec rspec")
    success &&= status
  end
  abort unless success
end

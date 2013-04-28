require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

ADAPTERS = %w(future_enabled_mysql2 future_enabled_postgresql postgresql mysql2)

desc "Runs the specs with all databases"
task :all do
  success = true
  ADAPTERS.each do |adapter|
    status = system({ "ADAPTER" => adapter }, "bundle exec rspec")
    success &&= status
  end
  abort unless success
end

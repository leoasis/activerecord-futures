require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

ADAPTERS = %w(future_enabled_postgresql future_enabled_mysql2 postgresql mysql2 sqlite3)

desc "Runs the specs with all databases"
task :all do
  success = true
  ADAPTERS.each do |adapter|
    status = system({ "ADAPTER" => adapter }, "bundle exec rspec")
    success &&= status
  end
  abort unless success
end

require "bundler/gem_tasks"

task :default => [:spec]

desc "Runs the specs"
task :spec do
  ["mysql", "postgresql"].each do |adapter|
    system({ "ADAPTER" => adapter }, "bundle exec rspec")
  end
end

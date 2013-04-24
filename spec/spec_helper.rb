require 'activerecord-futures'

mysql_config = {
  adapter: "future_enabled_mysql2",
  database: "test",
  username: "root",
  password: "root",
  database: "activerecord_futures_test",
  host: "localhost"
}
postgresql_config = {
  adapter: "future_enabled_postgresql",
  database: "test",
  username: "root",
  database: "activerecord_futures_test",
  host: "localhost"
}

config_var = "#{ENV['ADAPTER']}_config"
if local_variables.include?(config_var.to_sym)
  config = eval(config_var)
  puts "Using #{config_var} configuration"
else
  config = mysql_config
  puts "Using mysql_config configuration"
end

ActiveRecord::Base.establish_connection(config)
require 'db/schema'
Dir['./spec/models/**/*.rb'].each { |f| require f }

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

require 'rspec-spies'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.after do
    ActiveRecord::Futures::Future.clear
  end
end

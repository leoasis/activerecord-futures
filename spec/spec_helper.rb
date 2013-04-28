require 'coveralls'
Coveralls.wear!

require 'activerecord-futures'

configs = {
  future_enabled_mysql2: {
    adapter: "future_enabled_mysql2",
    database: "activerecord_futures_test",
    username: "root",
    encoding: "utf8"
  },
  future_enabled_postgresql: {
    adapter: "future_enabled_postgresql",
    database: "activerecord_futures_test",
    username: "postgres"
  },
  postgresql: {
    adapter: "postgresql",
    database: "activerecord_futures_test",
    username: "postgres"
  },
  mysql2: {
    adapter: "mysql2",
    database: "activerecord_futures_test",
    username: "root",
    encoding: "utf8"
  }
}

env_config = ENV['ADAPTER'].try(:to_sym)
config_key = configs.keys.include?(env_config) ? env_config : :future_enabled_mysql2
config = configs[config_key]
puts "Using #{config_key} configuration"

ActiveRecord::Base.establish_connection(config)
supports_futures =
  ActiveRecord::Base.connection.respond_to?(:supports_futures?) &&
  ActiveRecord::Base.connection.supports_futures?

require 'db/schema'
Dir['./spec/models/**/*.rb'].each { |f| require f }

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

require 'rspec-spies'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.filter_run_excluding(supports_futures ? :not_supporting_adapter : :supporting_adapter)
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.after do
    ActiveRecord::Futures::Future.clear
  end
end

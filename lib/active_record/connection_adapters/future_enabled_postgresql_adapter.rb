require 'active_record/connection_adapters/postgresql_adapter'
require "active_record/connection_adapters/future_enabled"

module ActiveRecord
  class Base
    # Establishes a connection to the database that's used by all Active Record objects
    def self.future_enabled_postgresql_connection(config) # :nodoc:
      config = config.symbolize_keys
      host     = config[:host]
      port     = config[:port] || 5432
      username = config[:username].to_s if config[:username]
      password = config[:password].to_s if config[:password]

      if config.key?(:database)
        database = config[:database]
      else
        raise ArgumentError, "No database specified. Missing argument: database."
      end

      # The postgres drivers don't allow the creation of an unconnected PGconn object,
      # so just pass a nil connection object for the time being.
      ConnectionAdapters::FutureEnabledPostgreSQLAdapter.new(nil, logger, [host, port, nil, nil, database, username, password], config)
    end
  end

  module ConnectionAdapters
    class FutureEnabledPostgreSQLAdapter < PostgreSQLAdapter
      include FutureEnabled

      def future_execute(sql, name)
        log(sql, name) do
          # Clear the queue
          @connection.get_last_result
          @connection.send_query(sql)
          @connection.block
          @connection.get_result
        end
      end

      def build_active_record_result(raw_result)
        return if raw_result.nil?
        result =  ActiveRecord::Result.new(raw_result.fields, result_as_array(raw_result))
        raw_result.clear
        result
      end

      def next_result
        @connection.get_result
      end
    end
  end
end

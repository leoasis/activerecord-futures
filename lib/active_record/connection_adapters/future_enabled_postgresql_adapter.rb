require 'active_record/connection_adapters/postgresql_adapter'

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
      def supports_futures?
        true
      end

      def exec_query(sql, name = 'SQL', binds = [])
        my_future = Futures::Future.current

        # default behavior if not a current future
        return super unless my_future

        # return fulfilled result, if exists, to load the relation
        return my_future.result if my_future.fulfilled?

        futures = Futures::Future.all

        futures_sql = futures.map(&:to_sql).join(';')
        name = "#{name} (fetching Futures)"

        result = log(futures_sql, name, binds) do
          # Clear the queue
          @connection.get_last_result
          @connection.send_query(futures_sql)
          @connection.block
          to_result(@connection.get_result)
        end

        futures.each do |future|
          future.fulfill(result)
          result = to_result(@connection.get_result)
        end

        my_future.result
      end

      def to_result(raw_result)
        return if raw_result.nil?
        result =  ActiveRecord::Result.new(raw_result.fields, result_as_array(raw_result))
        raw_result.clear
        result
      end
    end
  end
end

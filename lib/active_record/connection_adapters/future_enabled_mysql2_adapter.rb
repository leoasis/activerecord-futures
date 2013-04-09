require "active_record/connection_adapters/mysql2_adapter"

module ActiveRecord
  class Base
    def self.future_enabled_mysql2_connection(config)
      config = config.symbolize_keys

      config[:username] = 'root' if config[:username].nil?

      if Mysql2::Client.const_defined? :FOUND_ROWS
        config[:flags] = Mysql2::Client::FOUND_ROWS | Mysql2::Client::MULTI_STATEMENTS
      end
      client = Mysql2::Client.new(config)
      options = [config[:host], config[:username], config[:password], config[:database], config[:port], config[:socket], 0]
      ConnectionAdapters::FutureEnabledMysql2Adapter.new(client, logger, options, config)
    end
  end

  module ConnectionAdapters
    class FutureEnabledMysql2Adapter < Mysql2Adapter

      def supports_futures?
        true
      end

      def exec_query(sql, name = 'SQL', binds = [])
        my_future = Future.current

        # default behavior if not a current future
        return super unless my_future

        # return fulfilled result, if exists, to load the relation
        return my_future.result if my_future.fulfilled?

        futures = Future.all

        futures_sql = futures.map(&:to_sql).join(';')
        name = "#{name} (fetching Futures)"

        result = execute(futures_sql, name)

        futures.each do |future|
          future.fulfill(ActiveRecord::Result.new(result.fields, result.to_a))
          result = @connection.store_result if @connection.next_result
        end

        my_future.result
      end
    end
  end
end
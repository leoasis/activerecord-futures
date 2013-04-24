require "active_record/connection_adapters/mysql2_adapter"
require "active_record/connection_adapters/future_enabled"
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
      include FutureEnabled

      def future_execute(sql, name)
        execute(sql, name)
      end

      def build_active_record_result(raw_result)
        ActiveRecord::Result.new(raw_result.fields, raw_result.to_a)
      end

      def next_result
        @connection.store_result if @connection.next_result
      end
    end
  end
end
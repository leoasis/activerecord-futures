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

      def initialize(*args)
        super
        unless supports_futures?
          logger.warn("ActiveRecord::Futures - You're using the mysql2 future "\
            "enabled adapter with an old version of the mysql2 gem. You must "\
            "use a mysql2 gem version higher than or equal to 0.3.12b1 to take "\
            "advantage of futures.\nFalling back to normal query execution behavior.")
        end
      end

      def supports_futures?
        # Support only if the mysql client allows fetching multiple statements
        # results
        @connection.respond_to?(:store_result)
      end

      def future_execute(arels, binds, name)
        sql = arels.zip(binds).map { |arel, bind| to_sql(arel, bind.try(:dup)) }.join(';')
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
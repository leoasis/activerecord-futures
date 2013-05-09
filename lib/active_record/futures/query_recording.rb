module ActiveRecord
  module Futures
    module QueryRecording

    private
      def record_query
        orig_klass = @klass
        connection = ConnectionProxy.new(@klass.connection)
        @klass = KlassProxy.new(@klass, connection)
        yield
        @loaded = false
        [connection.recorded_query, connection.recorded_binds]
      ensure
        @klass = orig_klass
      end

      class KlassProxy < Proxy
        attr_reader :klass, :connection

        def initialize(klass, connection)
          super(klass)
          @klass = klass
          @connection = connection
        end

        def build_default_scope
          scope = @klass.send(:build_default_scope)
          scope.instance_variable_set(:@klass, self)
          scope
        end

        def find_by_sql(sql, binds = [])
          connection.recorded_query = sanitize_sql(sql)
          connection.recorded_binds = binds
          []
        end
      end

      class ConnectionProxy < Proxy
        attr_reader :connection
        attr_accessor :recorded_query, :recorded_binds

        def initialize(connection)
          super(connection)
          @connection = connection
        end

        def select_value(arel, name = nil)
          self.recorded_query = arel
          nil
        end

        def select_all(arel, name = nil, binds = [])
          self.recorded_query = arel
          []
        end
      end
    end
  end
end
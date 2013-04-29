module ActiveRecord
  module Futures
    module QueryRecording

    private
      def record_query
        orig_klass = @klass
        connection = ConnectionProxy.new(@klass.connection)
        @klass = KlassProxy.new(@klass, connection)
        yield
        [connection.recorded_query, connection.query_type]
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
      end

      class ConnectionProxy < Proxy
        attr_reader :connection
        attr_accessor :recorded_query, :query_type

        def initialize(connection)
          super(connection)
          @connection = connection
        end

        def select_value(arel, name = nil)
          self.query_type = :value
          self.recorded_query = arel.to_sql
          nil
        end

        def select_all(arel, name = nil, binds = [])
          self.query_type = :all
          self.recorded_query = arel.to_sql
          []
        end
      end
    end
  end
end
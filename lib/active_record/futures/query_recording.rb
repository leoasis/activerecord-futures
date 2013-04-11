module ActiveRecord
  module Futures
    module QueryRecording

    private
      def record_query
        orig_klass = @klass
        connection = ConnectionProxy.new(@klass.connection)
        @klass = KlassProxy.new(@klass, connection)
        yield
        connection.recorded_query
      ensure
        @klass = orig_klass
      end

      class KlassProxy
        attr_reader :klass, :connection

        def initialize(klass, connection)
          @klass = klass
          @connection = connection
        end

        def method_missing(method, *args, &block)
          if klass.respond_to?(method)
            klass.send(method, *args, &block)
          else
            super
          end
        end

        def respond_to?(method, include_all = false)
          super || klass.respond_to?(method, include_all)
        end
      end

      class ConnectionProxy
        attr_reader :connection
        attr_accessor :recorded_query

        def initialize(connection)
          @connection = connection
        end

        def select_value(arel, name = nil)
          self.recorded_query = arel.to_sql
          nil
        end

        def select_all(arel, name = nil, binds = [])
          self.recorded_query = arel.to_sql
          []
        end

        def method_missing(method, *args, &block)
          if connection.respond_to?(method)
            connection.send(method, *args, &block)
          else
            super
          end
        end

        def respond_to?(method, include_all = false)
          super || connection.respond_to?(method, include_all)
        end
      end
    end
  end
end
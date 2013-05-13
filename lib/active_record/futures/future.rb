module ActiveRecord
  module Futures
    class Future
      attr_reader :result, :relation, :query, :binds, :execution
      private :relation, :execution

      def initialize(relation, query, binds, execution)
        @relation = relation
        @query = query
        @binds = binds
        @execution = execution
        FutureRegistry.register(self)
      end

      def fulfill(result)
        @result = result
      end

      def fulfilled?
        !result.nil?
      end

      def load
        # Only perform a load if the adapter supports futures.
        # This allows to fallback to normal query execution in futures
        # when the adapter does not support futures.
        return unless connection_supports_futures?
        FutureRegistry.current = self
        execute(false)
        FutureRegistry.current = nil
      end

      def execute(flush = true)
        # Flush all the futures upon first attempt to exec a future
        FutureRegistry.flush if flush && !executed?

        unless executed?
          @value = execution.call
          @executed = true
        end

        @value
      end

      def executed?
        @executed
      end

    private
      def connection_supports_futures?
        conn = relation.connection
        conn.respond_to?(:supports_futures?) && conn.supports_futures?
      end
    end
  end
end
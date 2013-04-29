module ActiveRecord
  module Futures
    class Future
      class << self
        def futures
          Thread.current["#{self.name}_futures"] ||= []
        end
        alias_method :all, :futures

        def current
          Thread.current["#{self.name}_current"]
        end

        def current=(future)
          Thread.current["#{self.name}_current"] = future
        end

        def clear
          all.clear
        end

        def register(future)
          self.futures << future
        end

        def flush
          self.futures.each(&:load)
          clear
        end

      private
        def fetch_with(method)
          define_method(method) do
            # Flush all the futures upon first attempt to exec a future
            Future.flush unless executed?
            execute
          end
        end
      end


      attr_reader :result, :relation
      private :relation

      def initialize(relation)
        @relation = relation
        Future.register(self)
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
        Future.current = self
        execute
        Future.current = nil
      end

      def to_sql
      end
      undef_method :to_sql

    private
      def execute
      end
      undef_method :execute

      def executed?
      end
      undef_method :executed?

      def connection_supports_futures?
        conn = relation.connection
        conn.respond_to?(:supports_futures?) && conn.supports_futures?
      end

    end
  end
end
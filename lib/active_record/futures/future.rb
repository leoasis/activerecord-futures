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
        def fetch_with(method, &block)
          define_method(method) do
            # Flush all the futures upon first attempt to exec a future
            Future.flush unless executed?
            instance_eval(&block)
          end
        end
      end


      attr_reader :result

      def initialize
        Future.register(self)
      end

      def fulfill(result)
        @result = result
      end

      def fulfilled?
        !result.nil?
      end

      def load
        Future.current = self
        execute
        Future.current = nil
      end

      def inspect
        to_a.inspect
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

    end
  end
end
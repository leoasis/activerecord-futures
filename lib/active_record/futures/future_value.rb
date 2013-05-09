module ActiveRecord
  module Futures
    class FutureValue
      attr_reader :future_execution
      private :future_execution

      def initialize(future_execution)
        @future_execution = future_execution
      end

      def value
        future_execution.execute
      end

      def inspect
        value
      end
    end
  end
end
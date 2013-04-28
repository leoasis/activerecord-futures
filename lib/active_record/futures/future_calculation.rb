module ActiveRecord
  module Futures
    class FutureCalculation < Future
      attr_reader :query, :execution
      private :query, :execution

      def initialize(query, execution)
        super()
        @query = query
        @execution = execution
      end

      def inspect
        value.inspect
      end

      def to_sql
        query
      end

    private

      def execute
        @value = execution.call
        @executed = true
      end

      def executed?
        @executed
      end
    end
  end
end
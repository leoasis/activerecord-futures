module ActiveRecord
  module Futures
    class FutureCalculation < Future
      attr_reader :query, :execution
      private :query, :execution

      def initialize(relation, query, execution)
        super(relation)
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
        @value = execution.call unless executed?
        @executed = true
        @value
      end

      def executed?
        @executed
      end
    end
  end
end
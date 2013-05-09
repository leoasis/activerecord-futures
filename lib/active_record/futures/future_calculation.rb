module ActiveRecord
  module Futures
    class FutureCalculation < Future
      attr_reader :query, :binds, :execution
      private :execution

      def initialize(relation, query, binds, execution)
        super(relation)
        @query = query
        @binds = binds
        @execution = execution
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
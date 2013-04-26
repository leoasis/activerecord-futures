module ActiveRecord
  module Futures
    class FuturePluck < Future
      include ActiveRecord::Delegation

      attr_reader :query, :execution
      private :query, :execution

      def initialize(query, execution)
        super()
        @query = query
        @execution = execution
      end

      fetch_with(:to_a) { @value }

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
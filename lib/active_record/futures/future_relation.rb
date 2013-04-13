module ActiveRecord
  module Futures
    class FutureRelation < Future
      include Delegation
      delegate :to_sql, to: :relation

      attr_reader :relation
      private :relation

      def initialize(relation)
        super()
        @relation = relation
        @klass = relation.klass
      end

      fetch_with(:to_a) { execute }

    private

      def execute
        relation.to_a
      end

      def executed?
        relation.loaded?
      end
    end
  end
end
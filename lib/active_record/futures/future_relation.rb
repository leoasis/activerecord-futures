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

      def to_a
        # Flush all the futures upon first attempt to exec a future
        Future.flush unless executed?
        execute
      end

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
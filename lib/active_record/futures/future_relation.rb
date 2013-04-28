module ActiveRecord
  module Futures
    class FutureRelation < Future
      include ActiveRecord::Delegation

      attr_reader :relation
      private :relation

      def initialize(relation)
        super()
        @relation = relation
        @klass = relation.klass

        # Eagerly get sql from relation, since PostgreSQL adapter may use the
        # same method `exec_query` to retrieve the columns when executing
        # `to_sql`, and that will cause an infinite loop if a current future
        # exists
        @query = relation.to_sql
      end

      fetch_with(:to_a)

      def to_sql
        @query
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
module ActiveRecord
  class Future
    include Delegation
    delegate :to_sql, to: :relation

    class << self
      # This should be set in a thread scope
      attr_accessor :current

      def all
        # Make this live together with the connection
        # or thread based
        @futures ||= []
      end

      def clear
        all.clear
      end

      def register(future)
        @futures ||= []
        @futures << future
      end

      def flush
        all.each(&:load)
        clear
      end
    end

    attr_reader :result, :relation

    def initialize(relation)
      Future.register(self)

      @relation = relation
      @klass = relation.klass
    end

    def fulfill(result)
      @result = result
    end

    def fulfilled?
      !result.nil?
    end

    def load
      Future.current = self
      relation.to_a
      Future.current = nil
    end

    def to_a
      # Flush all the futures upon first attempt to exec a future
      Future.flush unless relation.loaded?
      relation.to_a
    end

    def inspect
      to_a.inspect
    end
  end
end
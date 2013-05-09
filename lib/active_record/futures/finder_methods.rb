module ActiveRecord
  module Futures
    module FinderMethods
      extend ActiveSupport::Concern

      def future_find(*args, &block)
        exec = -> { find(*args, &block) }
        query, binds = record_query do
          begin
            exec.call
          rescue RecordNotFound
            nil
          end
        end

        args = args.dup
        args.extract_options!
        expects_array = block_given? || args.first == :all ||
                        args.first.kind_of?(Array) || args.size > 1

        if expects_array
          FutureCalculationArray.new(self, query, binds, exec)
        else
          FutureCalculationValue.new(self, query, binds, exec)
        end
      end

      def future_all(*args, &block)
        exec = -> { all(*args, &block) }
        query, binds = record_query(&exec)
        FutureCalculationArray.new(self, query, binds, exec)
      end

      included do
        methods = original_finder_methods - [:find, :all]

        # define a "future_" method for each finder method
        #
        methods.each do |method|
          define_method(futurize(method)) do |*args, &block|
            exec = lambda { send(method, *args, &block) }
            query, binds = record_query(&exec)
            FutureCalculationValue.new(self, query, binds, exec)
          end
        end
      end

      module ClassMethods
        def original_finder_methods
          [:find, :first, :last, :exists?, :all]
        end

        def future_finder_methods
          original_finder_methods.map { |method| futurize(method) }
        end
      end
    end
  end
end
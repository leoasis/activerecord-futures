module ActiveRecord
  module Futures
    module Delegation
      delegate :future, to: :scoped
      delegate *Futures.future_calculation_methods, to: :scoped
      delegate *Futures.future_finder_methods, to: :scoped
    end
  end
end
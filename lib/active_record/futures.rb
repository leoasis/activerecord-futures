module ActiveRecord
  module Futures
    def future
      supports_futures = connection.respond_to?(:supports_futures?) &&
                         connection.supports_futures?

      # simply pass through if the connection adapter does not support
      # futures
      supports_futures ? Future.new(self) : self
    end
  end
end
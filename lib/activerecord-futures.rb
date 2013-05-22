require 'active_record'
require 'active_support/core_ext/module/delegation'
require "activerecord-futures/version"

require "active_record/futures/future_registry"
require "active_record/futures/future"
require "active_record/futures/future_array"
require "active_record/futures/future_value"

require "active_record/futures/proxy"
require "active_record/futures/query_recording"
require "active_record/futures/finder_methods"
require "active_record/futures/calculation_methods"
require "active_record/futures"
require "active_record/futures/delegation"

require "active_record/futures/middleware" if defined?(Rack)
require "active_record/futures/railtie" if defined?(Rails)

module ActiveRecord
  class Relation
    include Futures
  end

  class Base
    extend Futures::Delegation
  end
end

class ActiveRecord::Base::ConnectionSpecification
  class Resolver
    def spec_with_futures
      spec = spec_without_futures
      begin
        config = spec.config
        future_adapter_name = "future_enabled_#{config[:adapter]}"

        # Try to load the future version of the adapter
        require "active_record/connection_adapters/#{future_adapter_name}_adapter"

        config[:adapter] = future_adapter_name
        adapter_method = "future_enabled_#{spec.adapter_method}"

        # Return the specification with the future adapter instead
        ActiveRecord::Base::ConnectionSpecification.new(config, adapter_method)
      rescue LoadError
        # No future version of the adapter, or the adapter was already a future
        # one. Keep going as usual...
        spec
      end
    end

    alias_method_chain :spec, :futures
  end
end
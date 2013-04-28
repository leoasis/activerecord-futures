require 'active_record'
require 'active_support/core_ext/module/delegation'
require "activerecord-futures/version"

require "active_record/futures/future"
require "active_record/futures/future_relation"
require "active_record/futures/future_calculation"
require "active_record/futures/future_calculation_value"
require "active_record/futures/future_calculation_array"

require "active_record/futures/proxy"
require "active_record/futures/query_recording"
require "active_record/futures"
require "active_record/futures/delegation"

module ActiveRecord
  class Relation
    include Futures
  end

  class Base
    extend Futures::Delegation
  end
end
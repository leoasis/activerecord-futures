require 'active_record'
require "activerecord-futures/version"
require "active_record/future"
require "active_record/futures"

module ActiveRecord
  class Relation
    include Futures
  end
end
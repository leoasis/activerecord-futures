RSpec::Matchers.define :exec do |expected|

  match do |block|
    query_count(&block) == expected
  end

  chain :queries do
  end

  chain :query do
  end

  failure_message_for_should do |actual|
    "Expected to execute #{expected} queries, executed #{@query_counter.query_count}: #{@query_counter.queries}"
  end

  failure_message_for_should_not do |actual|
    "Expected to not execute #{expected} queries"
  end

  def query_count(&block)
    @query_counter = QueryCounter.new
    ActiveSupport::Notifications.subscribed(@query_counter.method(:call), 'sql.active_record', &block)
    @query_counter.query_count
  end

  class QueryCounter
    attr_accessor :query_count
    attr_accessor :queries

    IGNORED_SQL = [
      /^PRAGMA (?!(table_info))/,
      /^SELECT currval/,
      /^SELECT CAST/,
      /^SELECT @@IDENTITY/,
      /^SELECT @@ROWCOUNT/,
      /^SAVEPOINT/,
      /^ROLLBACK TO SAVEPOINT/,
      /^RELEASE SAVEPOINT/,
      /^SHOW max_identifier_length/,
      /SHOW/
    ]

    def initialize
      self.query_count = 0
      self.queries = []
    end

    def call(name, start, finish, message_id, values)
      # FIXME: this seems bad. we should probably have a better way to indicate
      # the query was cached
      unless 'CACHE' == values[:name]
        unless IGNORED_SQL.any? { |r| values[:sql] =~ r }
          self.query_count += 1
          self.queries << values[:sql]
        end
      end
    end
  end

end
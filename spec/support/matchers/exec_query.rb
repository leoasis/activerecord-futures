RSpec::Matchers.define :exec_query do |expected|

  match do |block|
    query(&block) == expected
  end

  failure_message_for_should do |actual|
    "Expected to execute #{expected}, got #{@query}"
  end

  failure_message_for_should_not do |actual|
    "Expected to not execute #{expected}, got #{actual}"
  end

  def query(&block)
    query = lambda do |name, start, finish, message_id, values|
      @query = values[:sql]
    end
    ActiveSupport::Notifications.subscribed(query, 'sql.active_record', &block)
    @query
  end

end
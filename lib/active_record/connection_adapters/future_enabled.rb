module ActiveRecord
  module ConnectionAdapters
    module FutureEnabled
      def supports_futures?
        true
      end

      def exec_query(sql, name = 'SQL', binds = [])
        my_future = Futures::Future.current

        # default behavior if not a current future or not executing
        # the current future's sql (some adapters like PostgreSQL
        # may execute some attribute queries during a relation evaluation)
        return super unless my_future && my_future.to_sql == sql

        # return fulfilled result, if exists, to load the relation
        return my_future.result if my_future.fulfilled?

        futures = Futures::Future.all
        futures_sql = futures.map(&:to_sql).join(';')
        name = "#{name} (fetching Futures)"

        result = future_execute(futures_sql, name)

        futures.each do |future|
          future.fulfill(build_active_record_result(result))
          result = next_result
        end

        my_future.result
      end
    end
  end
end
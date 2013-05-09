module ActiveRecord
  module ConnectionAdapters
    module FutureEnabled
      def supports_futures?
        true
      end

      def exec_query(sql, name = 'SQL', binds = [])
        my_future = Futures::FutureRegistry.current

        # default behavior if not a current future or not executing
        # the current future's sql (some adapters like PostgreSQL
        # may execute some attribute queries during a relation evaluation)
        return super if !my_future || to_sql(my_future.query, my_future.binds.try(:dup)) != sql

        # return fulfilled result, if exists, to load the relation
        return my_future.result if my_future.fulfilled?

        futures = Futures::FutureRegistry.all
        future_arels = futures.map(&:query)
        future_binds = futures.map(&:binds)
        name = "#{name} (fetching Futures)"

        result = future_execute(future_arels, future_binds, name)

        futures.each do |future|
          future.fulfill(build_active_record_result(result))
          result = next_result
        end

        my_future.result
      end
    end
  end
end
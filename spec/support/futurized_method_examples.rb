shared_examples "a futurized method" do |exec_trigger|
  describe "##{exec_trigger}" do
    let(:future_execution) { future.send(:future_execution) }
    let(:calling_future) { -> { future.send(exec_trigger) } }

    specify(nil, :supporting_adapter) { future_execution.should_not be_fulfilled }

    specify do
      calling_future.should exec(1).query
    end

    specify(nil, postgresql: false) do
      calling_future.should exec_query(future_sql)
    end

    specify(nil, postgresql: true) do
      sql = respond_to?(:future_sql_postgresql) ? future_sql_postgresql : future_sql
      calling_future.should exec_query(sql)
    end

    specify { future.send(exec_trigger).should eq relation_result }

    context "after executing the future" do
      before do
        future.send(exec_trigger)
      end

      specify(nil, :supporting_adapter) { future_execution.should be_fulfilled }
    end

    context "executing it twice" do
      before do
        future.send(exec_trigger)
      end

      specify do
        calling_future.should exec(0).queries
      end

      specify { future.send(exec_trigger).should eq relation_result }
    end
  end
end
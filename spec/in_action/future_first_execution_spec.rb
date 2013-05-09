require 'spec_helper'

describe "future_first method" do
  let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
  let(:first) { relation.future_first }
  let(:first_execution) { first.send(:future_execution) }
  let(:first_sql) do
    arel = relation.arel
    arel.limit = 1
    arel.to_sql
  end

  before do
    Post.create(published_at: Time.new(2012, 12, 10))
    Post.create(published_at: Time.new(2012, 6, 23))
    Post.create(published_at: Time.new(2013, 4, 5))
  end

  describe "#value" do
    let(:calling_value) { -> { first.value } }

    specify(nil, :supporting_adapter) { first_execution.should_not be_fulfilled }

    specify do
      calling_value.should exec(1).query
    end

    specify do
      calling_value.should exec_query(first_sql)
    end

    specify { first.value.should eq relation.first }

    context "after executing the future" do
      before do
        first.value
      end

      specify(nil, :supporting_adapter) { first_execution.should be_fulfilled }
    end

    context "executing it twice" do
      before do
        first.value
      end

      specify do
        calling_value.should exec(0).queries
      end

      specify { first.value.should eq relation.first }
    end
  end
end
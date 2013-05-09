require 'spec_helper'

describe "future_last method" do
  let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
  let(:last) { relation.future_last }
  let(:last_execution) { last.send(:future_execution) }
  let(:last_sql) do
    arel = relation.arel
    arel.order("#{relation.quoted_table_name}.#{relation.quoted_primary_key} DESC")
    arel.limit = 1
    arel.to_sql
  end

  before do
    Post.create(published_at: Time.new(2012, 12, 10))
    Post.create(published_at: Time.new(2012, 6, 23))
    Post.create(published_at: Time.new(2013, 4, 5))
  end

  describe "#value" do
    let(:calling_value) { -> { last.value } }

    specify(nil, :supporting_adapter) { last_execution.should_not be_fulfilled }

    specify do
      calling_value.should exec(1).query
    end

    specify do
      calling_value.should exec_query(last_sql)
    end

    specify { last.value.should eq relation.last }

    context "after executing the future" do
      before do
        last.value
      end

      specify(nil, :supporting_adapter) { last_execution.should be_fulfilled }
    end

    context "executing it twice" do
      before do
        last.value
      end

      specify do
        calling_value.should exec(0).queries
      end

      specify { last.value.should eq relation.last }
    end
  end
end
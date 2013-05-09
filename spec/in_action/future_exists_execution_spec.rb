require 'spec_helper'

describe "future_exists? method" do
  let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
  let(:exists?) { relation.future_exists? }
  let(:exists_sql) do
    arel = relation.arel
    arel.projections = []
    arel.project("1 AS one")
    arel.limit = 1
    arel.to_sql
  end

  before do
    Post.create(published_at: Time.new(2012, 12, 10))
    Post.create(published_at: Time.new(2012, 6, 23))
    Post.create(published_at: Time.new(2013, 4, 5))
  end

  describe "#value" do
    let(:calling_value) { -> { exists?.value } }

    specify(nil, :supporting_adapter) { exists?.should_not be_fulfilled }

    specify do
      calling_value.should exec(1).query
    end

    specify do
      calling_value.should exec_query(exists_sql)
    end

    specify { exists?.value.should eq relation.exists? }

    context "after executing the future" do
      before do
        exists?.value
      end

      specify(nil, :supporting_adapter) { exists?.should be_fulfilled }
    end

    context "executing it twice" do
      before do
        exists?.value
      end

      specify do
        calling_value.should exec(0).queries
      end

      specify { exists?.value.should eq relation.exists? }
    end
  end
end
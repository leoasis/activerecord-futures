require 'spec_helper'

describe "future_count method" do
  let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
  let(:count) { relation.future_count }
  let(:count_sql) do
    arel = relation.arel
    arel.projections = []
    arel.project("COUNT(*)")
    arel.to_sql
  end

  before do
    Post.create(published_at: Time.new(2012, 12, 10))
    Post.create(published_at: Time.new(2012, 6, 23))
    Post.create(published_at: Time.new(2013, 4, 5))
  end

  describe "#value" do
    let(:calling_value) { -> { count.value } }

    specify do
      calling_value.should exec(1).query
    end

    specify do
      calling_value.should exec_query(count_sql)
    end

    specify { count.value.should eq 2 }

    context "executing it twice" do
      before do
        count.value
      end

      specify do
        calling_value.should exec(0).queries
      end

      specify { count.value.should eq 2 }
    end
  end
end
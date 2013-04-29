require 'spec_helper'

describe "future_pluck method" do
  let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
  let(:pluck) { relation.future_pluck('title') }
  let(:pluck_sql) do
    arel = relation.arel
    arel.projections = []
    arel.project('title')
    arel.to_sql
  end

  before do
    Post.create(title: "Post 1", published_at: Time.new(2012, 12, 10))
    Post.create(title: "Post 2", published_at: Time.new(2012, 6, 23))
    Post.create(title: "Post 3", published_at: Time.new(2013, 4, 5))
  end

  describe "#to_a" do
    let(:calling_to_a) { -> { pluck.to_a } }

    specify do
      calling_to_a.should exec(1).query
    end

    specify do
      calling_to_a.should exec_query(pluck_sql)
    end

    specify { pluck.to_a.should eq ["Post 1", "Post 2"] }

    context "executing it twice" do
      before do
        pluck.to_a
      end

      specify do
        calling_to_a.should exec(0).queries
      end

      specify { pluck.to_a.should eq ["Post 1", "Post 2"] }
    end
  end
end
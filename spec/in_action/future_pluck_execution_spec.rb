require 'spec_helper'

describe "future_pluck method" do
  let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
  let(:future) { relation.future_pluck('title') }
  let(:relation_result) { relation.pluck('title') }
  let(:future_sql) do
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

  it_behaves_like "a futurized method", :to_a
end
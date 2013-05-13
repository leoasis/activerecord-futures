require 'spec_helper'

describe "future_first method" do
  let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
  let(:future) { relation.future_first }
  let(:relation_result) { relation.first }
  let(:future_sql) do
    arel = relation.arel
    arel.limit = 1
    arel.to_sql
  end

  before do
    Post.create(published_at: Time.new(2012, 12, 10))
    Post.create(published_at: Time.new(2012, 6, 23))
    Post.create(published_at: Time.new(2013, 4, 5))
  end

  it_behaves_like "a futurized method", :value
end
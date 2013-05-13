require 'spec_helper'

describe "future_last method" do
  let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
  let(:future) { relation.future_last }
  let(:relation_result) { relation.last }
  let(:future_sql) do
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

  it_behaves_like "a futurized method", :value
end
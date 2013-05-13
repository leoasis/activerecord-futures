require 'spec_helper'

describe "future_all method" do
  context "with no parameters" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:future) { relation.future_all }
    let(:relation_result) { relation.all }
    let(:future_sql) do
      relation.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
    end

    it_behaves_like "a futurized method", :to_a
  end
end
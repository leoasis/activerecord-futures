require "spec_helper"

describe "future method" do

  before do
    Post.create(published_at: Time.new(2012, 12, 10))
    Post.create(published_at: Time.new(2012, 6, 23))
    Post.create(published_at: Time.new(2013, 4, 5))
  end

  def self.test_case(description, &relation_lambda)
    context "with a sample relation that #{description}" do
      let(:relation) { relation_lambda.call }
      let(:relation_result) { relation.to_a }
      let(:future) { relation.future }
      let(:future_sql) { relation.to_sql }

      it_behaves_like "a futurized method", :to_a
    end
  end

  test_case "filters by published_at" do
    Post.where("published_at < ?", Time.new(2013, 1, 1))
  end

  test_case "limits by 10" do
    Post.limit(10)
  end

end
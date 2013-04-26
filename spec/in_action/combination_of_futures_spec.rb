require "spec_helper"

describe "Combination of futures" do
  before do
    User.create(name: "Lenny")
    User.create(name: "John")
    User.create(name: "Julie")

    Post.create(title: "Post title 1", published_at: Time.new(2013, 3, 14))
    Post.create(title: "Post title 2", published_at: Time.new(2012, 11, 9))
    Post.create(title: "Post title 3")
  end

  let(:user_relation) { User.where(name: "Lenny") }
  let(:other_user_relation) { User.where("name like 'J%'") }

  let(:post_relation) { Post.where(title: "Post title 2") }

  let!(:user_future_relation) { user_relation.future }
  let!(:user_future_value) { other_user_relation.future_count }

  let!(:post_future_relation) { post_relation.future }
  let!(:post_future_value) { Post.future_count }

  context "the execution of any future" do
    subject { -> { post_future_relation.to_a } }

    let(:futures_sql) do
      [
        user_relation.to_sql,
        count(other_user_relation).to_sql,
        post_relation.to_sql,
        count(Post.scoped).to_sql
      ].join(';')
    end

    it { should exec(1).query }
    it { should exec_query(futures_sql) }

    def count(relation)
      arel = relation.arel
      arel.projections = []
      arel.project("COUNT(*)")
      arel
    end
  end

  context "having executed a future" do
    before do
      post_future_relation.to_a
    end

    context "the user future relation" do
      subject { user_future_relation }

      it { should be_fulfilled }

      its(:to_a) { should eq user_relation.to_a }
    end

    context "the user future value" do
      subject { user_future_value }

      it { should be_fulfilled }
      its(:value) { should eq other_user_relation.count }
    end

    context "the post future relation" do
      subject { post_future_relation }

      it { should be_fulfilled }
      its(:to_a) { should eq post_relation.to_a }
    end

    context "the post future value" do
      subject { post_future_value }

      it { should be_fulfilled }
      its(:value) { should eq Post.count }
    end
  end
end
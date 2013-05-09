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
  let(:user_relation_sql) { user_relation.to_sql }
  let!(:user_future_relation) { user_relation.future }

  let(:other_user_relation) { User.where("name like 'J%'") }
  let(:other_user_relation_count_sql) { count(other_user_relation).to_sql }
  let!(:user_future_value) { other_user_relation.future_count }

  let(:post_relation) { Post.where(title: "Post title 2") }
  let(:post_relation_sql) { post_relation.to_sql }
  let!(:post_future_relation) { post_relation.future }

  let(:post_count_sql) { count(Post.scoped).to_sql }
  let!(:post_future_value) { Post.future_count }

  context "the execution of any future" do
    subject { -> { post_future_relation.to_a } }

    context "execs only once with all queries", :supporting_adapter do
      let(:futures_sql) do
        [
          user_relation_sql,
          other_user_relation_count_sql,
          post_relation_sql,
          post_count_sql
        ].join(';')
      end

      it { should exec(1).query }
      it { should exec_query(futures_sql) }
    end

    context "execs just the executed future's query", :not_supporting_adapter do
      it { should exec(1).query }
      it { should exec_query(post_relation.to_sql) }
    end
  end

  context "having executed the post future" do
    before do
      post_future_relation.to_a
    end

    context "the user future relation" do
      subject { user_future_relation }

      it(nil, :supporting_adapter) { execution(subject).should be_fulfilled }
      it(nil, :not_supporting_adapter) { execution(subject).should_not be_fulfilled }

      describe "#to_a" do
        let(:calling_to_a) { ->{ subject.to_a } }

        its(:to_a) { should eq user_relation.to_a }

        context "when adapter supports futures", :supporting_adapter do
          specify { calling_to_a.should exec(0).queries }
        end

        context "when adapter does not support futures", :not_supporting_adapter do
          specify { calling_to_a.should exec(1).query }
          specify { calling_to_a.should exec_query(user_relation_sql) }
        end
      end
    end

    context "the user future value" do
      subject { user_future_value }

      it(nil, :supporting_adapter) { execution(subject).should be_fulfilled }
      it(nil, :not_supporting_adapter) { execution(subject).should_not be_fulfilled }

      describe "#value" do
        let(:calling_value) { ->{ subject.value } }

        its(:value) { should eq other_user_relation.count }

        context "when adapter supports futures", :supporting_adapter do
          specify { calling_value.should exec(0).queries }
        end

        context "when adapter does not support futures", :not_supporting_adapter do
          specify { calling_value.should exec(1).query }
          specify { calling_value.should exec_query(other_user_relation_count_sql) }
        end
      end
    end

    context "the post future relation" do
      subject { post_future_relation }

      it(nil, :supporting_adapter) { execution(subject).should be_fulfilled }
      it(nil, :not_supporting_adapter) { execution(subject).should_not be_fulfilled }

      describe "#to_a" do
        let(:calling_to_a) { ->{ subject.to_a } }

        its(:to_a) { should eq post_relation.to_a }

        context "when adapter supports futures", :supporting_adapter do
          specify { calling_to_a.should exec(0).queries }
        end

        context "when adapter does not support futures", :not_supporting_adapter do
          specify { calling_to_a.should exec(0).query }
          # No queries should be executed, since this is the future we executed
          # before
        end
      end
    end

    context "the post future value" do
      subject { post_future_value }

      it(nil, :supporting_adapter) { execution(subject).should be_fulfilled }
      it(nil, :not_supporting_adapter) { execution(subject).should_not be_fulfilled }

      describe "#value" do
        let(:calling_value) { ->{ subject.value } }

        its(:value) { should eq Post.count }

        context "when adapter supports futures", :supporting_adapter do
          specify { calling_value.should exec(0).queries }
        end

        context "when adapter does not support futures", :not_supporting_adapter do
          specify { calling_value.should exec(1).query }
          specify { calling_value.should exec_query(post_count_sql) }
        end
      end
    end
  end

  def execution(future)
    future.send(:future_execution)
  end

  def count(relation)
    arel = relation.arel
    arel.projections = []
    arel.project("COUNT(*)")
    arel
  end
end
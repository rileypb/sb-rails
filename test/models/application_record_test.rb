require 'test_helper'

class IssueTest < ActiveSupport::TestCase
	test "create_valid_order_nil" do
		issue = create(:issue)
		t1 = create(:task, issue: issue)
		t2 = create(:task, issue: issue)

		assert_equal "#{t1.id},#{t2.id}", issue.create_valid_order(issue.tasks, :task_order)
    end

	test "create_valid_order_missing_children" do
		issue = create(:issue)
		t1 = create(:task, issue: issue)
		t2 = create(:task, issue: issue)
		issue.task_order = "#{t2.id}"

		assert_equal "#{t2.id},#{t1.id}", issue.create_valid_order(issue.tasks, :task_order)
    end

	test "create_valid_order_extra_in_order" do
		issue = create(:issue)
		t1 = create(:task, issue: issue)
		t2 = create(:task, issue: issue)
		issue.task_order = "#{t2.id},#{t1.id},14"

		assert_equal "#{t2.id},#{t1.id}", issue.create_valid_order(issue.tasks, :task_order)
    end
end
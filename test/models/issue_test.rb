require 'test_helper'

class IssueTest < ActiveSupport::TestCase

  test "calculates progress" do
  	issue = create(:issue)
  	task1 = create(:task, issue: issue, estimate: 5, state: 'Open')
  	task2 = create(:task, issue: issue, estimate: 3, state: 'Closed')
  	task3 = create(:task, issue: issue, estimate: 2, state: 'In Progress')
  	assert_equal 30, issue.progress
  	task3.update(state: 'Closed')
  	assert_equal 50, issue.progress
  end

  test "calculates zero progress when total estimate is zero" do
  	issue = create(:issue)
  	task1 = create(:task, issue: issue, estimate: 0, state: 'Open')
  	task2 = create(:task, issue: issue, estimate: 0, state: 'Closed')
  	task3 = create(:task, issue: issue, estimate: 0, state: 'In Progress')
  	assert_equal 0, issue.progress
  end

end

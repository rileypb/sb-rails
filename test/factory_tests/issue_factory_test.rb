
require 'test_helper'
 
class IssueFactoryTest < ActiveSupport::TestCase
  test "single issue" do
    issue = create(:issue)
    assert_not_nil issue
    assert_not_nil issue.title
    assert_not_nil issue.description
    assert_not_nil issue.project
  end

  test "two issues" do
    issue = create(:issue)
  	issue1 = create(:issue)
    issue2 = create(:issue, project: issue1.project)
    assert_equal issue1.project, issue2.project
  end
end
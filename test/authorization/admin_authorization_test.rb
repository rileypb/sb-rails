require 'test_helper'

class AdminAuthorizationTest < ActiveSupport::TestCase
	test "admin can create delete issues in any project" do
		assert can?(:admin, :create, Issue)
		project = create(:project)
		assert can?(:admin, :create_issue, project)
		assert can?(:admin, :delete_issue, project)
	end

	test "admin can read update delete any issue" do
		issue = create(:issue)
		assert can?(:admin, :read, issue)
		assert can?(:admin, :update, issue)
		assert can?(:admin, :delete, issue)
	end

end
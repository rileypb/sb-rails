require 'test_helper'

class TransferControllerTest < ActionDispatch::IntegrationTest

	setup do
		@project = create(:project)
		@admin = create(:admin)

		get '/users/sign_in'
		sign_in @admin
		post user_session_url
	end

	test "transfer between epics" do
		epic1 = create(:epic, project: @project)
		epic2 = create(:epic, project: @project)
		i1 = create(:issue, project: @project, epic: epic1)
		i2 = create(:issue, project: @project, epic: epic1)
		i3 = create(:issue, project: @project, epic: epic1)
		i4 = create(:issue, project: @project, epic: epic2)
		i5 = create(:issue, project: @project, epic: epic2)
		i6 = create(:issue, project: @project, epic: epic2)
		epic1.update(issue_order: "#{i1.id},#{i2.id},#{i3.id}")
		epic2.update(issue_order: "#{i4.id},#{i5.id},#{i6.id}")

		patch transfer_issues_url, params: { transfer: { epicId1: epic1.id, epicId2: epic2.id, fromIndex: 0, toIndex: 1 } }
		
		epic1.reload
		epic2.reload
		i1.reload
		assert_response :no_content
		assert_equal "#{i2.id},#{i3.id}", epic1.issue_order
		assert_equal "#{i4.id},#{i1.id},#{i5.id},#{i6.id}", epic2.issue_order
		assert_equal epic2, i1.epic
	end

end
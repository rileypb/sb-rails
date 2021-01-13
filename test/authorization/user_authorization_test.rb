require 'test_helper'

class UserAuthorizationTest < ActiveSupport::TestCase
	test "any user can access projects, issues, and sprints" do
		assert can?(:user, :access, Project)
		assert can?(:user, :access, Issue)
		assert can?(:user, :access, Sprint)
	end

	test "user cannot read update most projects" do
		assert cannot?(:user, :read, create(:project))
		assert cannot?(:user, :update, create(:project))
	end

	test "user cannot create delete issues in most projects" do
		assert cannot?(:user, :create, Issue)
		assert cannot?(:user, :create_issue, create(:project))
		assert cannot?(:user, :delete_issue, create(:project))
	end

	test "user cannot read update issues in most projects" do
		assert cannot?(:user, :read, create(:issue))
		assert cannot?(:user, :update, create(:issue))
	end

	test "user cannot create delete sprints in most projects" do
		assert cannot?(:user, :create_sprint, create(:project))
		assert cannot?(:user, :delete_sprint, create(:project))
	end

	test "user cannot read update sprints in most projects" do
		assert cannot?(:user, :read, create(:sprint))
		assert cannot?(:user, :update, create(:sprint))
	end

	test "user cannot create delete tasks in most projects" do
		assert cannot?(:user, :create_tasks, create(:project))
		assert cannot?(:user, :delete_task, create(:project))
	end

	test "user cannot read update tasks in most projects" do
		assert cannot?(:user, :read, create(:task))
		assert cannot?(:user, :update, create(:task))
	end

	test "user can create delete issues in owned project" do
		user = create(:user)
		project = create(:project, owner: user)
		assert can?(user, :create_issue, project)
		assert can?(user, :delete_issue, project)
	end

	test "user can read update issues in owned project" do
		user = create(:user)
		project = create(:project, owner: user)
		issue = create(:issue, project: project)
		assert can?(user, :read, issue)
		assert can?(user, :update, issue)
	end

	test "user can read update owned project" do
		user = create(:user)
		project = create(:project, owner: user)
		assert can?(user, :read, project)
		assert can?(user, :update, project)
	end

	test "user can create delete sprints in owned project" do
		user = create(:user)
		project = create(:project, owner: user)
		assert can?(user, :create_sprint, project)
		assert can?(user, :delete_sprint, project)
	end

	test "user can read update sprints in owned project" do
		user = create(:user)
		project = create(:project, owner: user)
		sprint = create(:sprint, project: project)
		assert can?(user, :read, sprint)
		assert can?(user, :update, sprint)
	end

	test "user can create delete tasks in owned project" do
		user = create(:user)
		project = create(:project, owner: user)
		issue = create(:issue, project: project)
		assert can?(user, :create_task, issue)
		assert can?(user, :delete_task, issue)
	end

	test "user can read update tasks in owned project" do
		user = create(:user)
		project = create(:project, owner: user)
		issue = create(:issue, project: project)
		task = create(:task, issue: issue)
		assert can?(user, :read, task)
		assert can?(user, :update, task)
	end

	test "user cannot create delete projects" do
		assert cannot?(:user, :create, Project)
		assert cannot?(:user, :delete, Project)
	end


	
	############## Permissions ################

	# test "user with read permission can list issues" do
	# 	user = create(:user)
	# 	project = create(:project)

	# end
end
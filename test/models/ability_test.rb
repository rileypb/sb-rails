require 'test_helper'

class AbilityTest < ActiveSupport::TestCase

  ###################################
  # admins' abilities with projects #
  ###################################

  # test "admin can create projects" do
  # 	ability = Ability.new(users(:admin))
  # 	assert ability.can?(:create, Project)
  # end

  # test "admin can delete projects" do
  # 	ability = Ability.new(users(:admin))
  # 	assert ability.can?(:delete, Project)
  # end

  # test "admin can index projects" do
  # 	ability = Ability.new(users(:admin))
  # 	assert ability.can?(:access, Project)
  # end

  # test "admin can update projects" do
  # 	ability = Ability.new(users(:admin))
  # 	assert ability.can?(:update, Project)
  # 	assert ability.can?(:update, projects(:owned_by_admin))
  # 	assert ability.can?(:update, projects(:owned_by_member))
  # end

  # ####################################
  # # members' abilities with projects #
  # ####################################

  # test "member can index projects" do
  #   ability = Ability.new(users(:member))
  #   assert ability.can?(:access, Project)
  # end

  # test "member cannot create projects" do
  #   ability = Ability.new(users(:member))
  #   assert ability.cannot?(:create, Project)
  # end

  # test "member cannot delete projects" do
  #   ability = Ability.new(users(:member))
  #   assert ability.cannot?(:delete, Project)
  #   assert ability.cannot?(:delete, projects(:owned_by_admin))
  #   assert ability.cannot?(:delete, projects(:owned_by_member))
  # end

  # test "member can update own project" do
  #   ability = Ability.new(users(:member))
  #   assert ability.cannot?(:update, projects(:owned_by_admin))
  #   assert ability.can?(:update, projects(:owned_by_member))
  # end

  # test "member can update project with update permission" do
  #   ability = Ability.new(users(:member))
  #   assert ability.can?(:update, projects(:owned_by_admin_with_update_permissions))
  #   assert ability.cannot?(:read, projects(:owned_by_admin_with_update_permissions))
  # end

  # test "member can read project with read permission" do
  #   ability = Ability.new(users(:member))
  #   assert ability.can?(:read, projects(:owned_by_admin_with_read_permissions))
  #   assert ability.cannot?(:update, projects(:owned_by_admin_with_read_permissions))
  # end
end

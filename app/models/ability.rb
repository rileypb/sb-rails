# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      # admins can do anything
      if user.admin? || user.email == 'rileypb@gmail.com'
          can :manage, :all
          can :access, :rails_admin
          can :read, :dashboard
          can :create_issue, :all
      end

      can :access, Project
      can :access, Issue
      can :access, Sprint
      can :access, Epic
      can :access, Task

      # # project owner can do anything with the project
      can [:create_issue, :delete_issue, :read, :update], Project, owner: user
      can [:read, :update], Issue, project: { owner: user }
      can [:create_sprint, :delete_sprint], Project, owner: user
      can [:create_epic, :delete_epic], Project, owner: user
      can [:read, :update], Sprint, project: { owner: user }
      can [:read, :update], Task, issue: { project: { owner: user }}
      can [:read, :update], Epic, project: { owner: user }
      can [:create_task, :delete_task], Issue, project: { owner: user }

      # per project permissions
      can [:read], Project, project_permissions: { user: user, scope: "read" }
      can [:update], Project, project_permissions: { user: user, scope: "update" }
      can [:read], Sprint, project: { project_permissions: { user: user, scope: "read"}}
      can [:update], Sprint, project: { project_permissions: { user: user, scope: "update"}}
      can [:read], Epic, project: { project_permissions: { user: user, scope: "read"}}
      can [:update], Epic, project: { project_permissions: { user: user, scope: "update"}}
      can [:read], Issue, project: { project_permissions: { user: user, scope: "read"}}
      can [:update], Issue, project: { project_permissions: { user: user, scope: "update"}}
      can [:read], Task, issue: { project: { project_permissions: { user: user, scope: "read"}}}
      can [:update], Task, issue: {project: { project_permissions: { user: user, scope: "update"}}}

      can [:create_task, :delete_task], Issue, project: { project_permissions: { user: user, scope: "update" }}
    end
  end
end

class Project < ApplicationRecord
	has_many :project_permissions
	has_many :sprints
	has_many :epics
	has_many :issues
	has_many :activities
	has_many :child_activities, foreign_key: "project_context", class_name: "Activity"

	belongs_to :owner, class_name: 'User'
	belongs_to :current_sprint, class_name: 'Sprint', optional: true

	validates :name, presence: true
	validates :owner_id, presence: true
	validate :orders_are_valid
	validate :current_sprint_from_same_project

	def current_sprint_from_same_project
		if self.current_sprint && self.current_sprint.project != self
			errors.add(:current_sprint, "must be from same project")
		end
	end

    def orders_are_valid
    	validate_order(:issue_order)
    	validate_order(:epic_order)
    end

	def permissions(user)
		perms = super
  		ability = Ability.new(user)
		perms << 'create-issue' if ability.can? :create_issue, self
		perms << 'delete-issue' if ability.can? :delete_issue, self
	    perms << 'create-sprint' if ability.can? :create_sprint, self
	    perms << 'delete-sprint' if ability.can? :delete_sprint, self
	    perms << 'create-epic' if ability.can? :create_epic, self
	    perms << 'delete-epic' if ability.can? :delete_epic, self
		return perms
	end

	def add_issue(issue)
		if self.issue_order
	    	self.issue_order += ",#{issue.id}"
	    else
	    	self.issue_order = "#{issue.id}"
	    end
	    self.save
	end

end

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
	validate :issue_order_length
	validate :epic_order_length

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
  		perms << 'configure' if ability.can? :configure, self
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
	    self.save!
	end

	def update_burndown_data!
		if current_sprint
			points_remaining = current_sprint.issues.where('state <> ?', 'Closed').sum(:estimate)

			day = Time.now.midnight.to_i/(24*3600)

			current_sprint.set_burndown_data!(day, points_remaining)
		end
	end

	def team_members(current_user = nil)
		result = [ self.owner ]
		result.concat(self.project_permissions.map { |pp| pp.user })
		if self.demo
			result.concat(User.where(demo: true)) # if this is a demo project, add demo users
		end
		result << current_user if current_user
		result.uniq!
		return result.sort_by { |u| u.orderable_name }
	end



    def create_valid_order(children, order_field)
      order = self.attributes[order_field.to_s] || ''
      order_split = order.split(',').map { |x| x.to_i }
      if order_field == :issue_order
	      child_ids = children.where('sprint_id is NULL').map { |child| child.id }
	  else
	      child_ids = children.map { |child| child.id }
	  end
      extras = order_split - child_ids
      leftovers = child_ids - order_split
      new_order_split = order_split - extras + leftovers
      new_order = new_order_split.join(',')
      return new_order
    end


	private

	def issue_order_length
		project_issues = self.issues.where('sprint_id is NULL')
		validate_order_length(project_issues, :issue_order)
	end

	def epic_order_length
		validate_order_length(self.epics, :epic_order)
	end
end

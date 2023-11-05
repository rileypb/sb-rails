class Issue < ApplicationRecord
	belongs_to :project
	belongs_to :sprint, optional: true
	belongs_to :epic, optional: true
	belongs_to :last_changed_by, class_name: 'User', optional: true
	has_many :tasks
	has_many :activities
	belongs_to :parent, class_name: 'Issue', optional: true
	belongs_to :assignee, class_name: 'User', optional: true
	has_many :comments
	has_many :acceptance_criteria

	validate :orders_are_valid
	validate :task_order_length

	def progress
		totalEstimate = tasks.sum("estimate")
		return 0 if totalEstimate == 0

		totalFinished = tasks.where(state: "Closed").sum("estimate")
		return (100 * totalFinished / totalEstimate).round
	end

	def permissions(user)
		perms = super
  		ability = Ability.new(user)
		perms << 'create-task' if ability.can? :create_task, self
		perms << 'delete-task' if ability.can? :delete_task, self
		perms << 'accept_ac' if ability.can? :accept_ac, self
		return perms
	end

	def add_task(task)
		if self.task_order
			self.task_order += ",#{task.id}"
		else
			self.task_order = "#{task.id}"
		end
		self.save
	end

    def orders_are_valid
    	validate_order(:task_order)
    end

    def task_order_length
    	validate_order_length(self.tasks, :task_order)
    end

	def closed?
		return self.state == "Closed"
	end

    def closable
      project = self.project
      sprint = self.sprint
	  if sprint && sprint.closed?
		return true
	  end
	  if sprint && project.current_sprint == sprint.id
		return true
	  end
      if !project.allow_issue_completion_without_sprint
		return false
	  else
        if sprint && !project.current_sprint == sprint.id 
          return false
        end
      end
      return true
    end
end
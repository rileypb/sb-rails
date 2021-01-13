class Issue < ApplicationRecord
	belongs_to :project
	belongs_to :sprint, optional: true
	belongs_to :epic, optional: true
	belongs_to :last_changed_by, class_name: 'User', optional: true
	has_many :tasks
	has_many :activities
	belongs_to :parent, class_name: 'Issue', optional: true
	belongs_to :assignee, class_name: 'User', optional: true

	validate :orders_are_valid

	def progress
		totalEstimate = tasks.sum("estimate")
		return 0 if totalEstimate == 0

		totalFinished = tasks.where(state: "Done").sum("estimate")
		return (100 * totalFinished / totalEstimate).round
	end

	def permissions(user)
		perms = super
  		ability = Ability.new(user)
		perms << 'create-task' if ability.can? :create_task, self
		perms << 'delete-task' if ability.can? :delete_task, self
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
end
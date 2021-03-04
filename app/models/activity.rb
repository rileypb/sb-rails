class Activity < ApplicationRecord
	belongs_to :project, optional: true
	belongs_to :sprint, optional: true
	belongs_to :sprint2, class_name: 'Sprint', optional: true
	belongs_to :issue, optional: true
	belongs_to :task, optional: true
	belongs_to :epic, optional: true
	belongs_to :epic2, class_name: 'Epic', optional: true

	belongs_to :user
	belongs_to :user2, class_name: 'User', optional: true
	belongs_to :project_context, class_name: 'Project'

end

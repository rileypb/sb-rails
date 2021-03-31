class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :issue, optional: true
  belongs_to :epic, optional: true
  belongs_to :sprint, optional: true
  belongs_to :project, optional: true

  belongs_to :project_context, class_name: 'Project'
end

class ProjectPermission < ApplicationRecord
  belongs_to :project
  belongs_to :user

  def label
  	"#{self.user && self.user.label}:#{self.project && self.project.name}:#{self.scope}"
  end
end

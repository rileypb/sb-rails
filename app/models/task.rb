class Task < ApplicationRecord
	belongs_to :issue
	belongs_to :last_changed_by, class_name: 'User', optional: true
end

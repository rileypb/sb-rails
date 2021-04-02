class NewsItem < ApplicationRecord
	belongs_to :comment, optional: true
	belongs_to :user

	validates_presence_of :user
end

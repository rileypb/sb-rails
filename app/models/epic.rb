class Epic < ApplicationRecord
	belongs_to :project
	has_many :issues
	has_many :activities

	validate :orders_are_valid

	def issues_in_order
		order = (issue_order || '').split(',')
    	iss = []
	    order.each do |i|
	      this_issue = issues.find(i) rescue nil
	      if this_issue
	        iss << this_issue
	      end
	    end
	    issues.each do |i|
	      iss << i if !iss.include?(i)
	    end
	end

    def orders_are_valid
    	validate_order(:issue_order)
    end
end

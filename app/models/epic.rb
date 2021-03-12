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

	def append_to_order(order_string, to_append)
		order_string ||= ''
		split = order_string.split(',')
		if !split.include? to_append
			split << to_append
			return split.join(',')
		end
		return order_string
	end

    def append_issue(issue)
    	issue.update!(epic: self)
    	self.update!(issue_order: append_to_order(self.issue_order, issue.id))
    end
end

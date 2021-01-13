class Sprint < ApplicationRecord
	belongs_to :project
	has_many :issues

	validate :orders_are_valid

	def permissions(user)
		perms = super
  		ability = Ability.new(user)
		perms << 'create-issue' if ability.can? :create_issue, self
		perms << 'delete-issue' if ability.can? :delete_issue, self
		return perms
	end

	def add_issue(issue)
		if self.issue_order
	    	self.issue_order += ",#{issue.id}"
	    else
	    	self.issue_order = "#{issue.id}"
	    end
	    self.save
    end

    def orders_are_valid
    	validate_order(:issue_order)
    end

    def set_burndown_data!(day, value)
    	sql = "select count() from burndown_data where day=#{day} and sprint_id=#{self.id}"
    	result = ActiveRecord::Base.connection.execute(sql)
    	count = result[0]["count()"]
    	if count > 0
    		sql = "update burndown_data set value = #{value} where day=#{day} and sprint_id=#{self.id}"
    		result = ActiveRecord::Base.connection.execute(sql)
    		puts result
    	else
    		sql = "insert into burndown_data (day, value, sprint_id) values (#{day}, #{value}, #{self.id})"
    		result = ActiveRecord::Base.connection.execute(sql)
    		puts result
    	end
    end

    def burndown_data
    	sql = "select day, value from burndown_data where sprint_id=#{self.id} order by day"
    	ActiveRecord::Base.connection.execute(sql)
    end

    def burndown_data_string
    	result = self.burndown_data
    	x = result.map do |entry|
    		"{#{entry['day']},#{entry['value']}}"
    	end
    	"[" + x.join(",") + "]"
    end

    def burndown_graph
    	{
    		xAxisData: ['10/1', '10/2', '10/3', '10/4', '10/5', '10/6'],
    		ideal: [50,40,30,20,10,0],
    		actual: [50,42,36],
    		projected: [nil,nil,36,24,12,0]
    	}
    end
end
	
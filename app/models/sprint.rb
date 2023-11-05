class Sprint < ApplicationRecord
	belongs_to :project
	has_many :issues
    has_many :comments
    
	validate :orders_are_valid
    validate :issue_order_length

	def permissions(user)
		perms = super
  		ability = Ability.new(user)
		perms << 'create-issue' if ability.can? :create_issue, self
		perms << 'delete-issue' if ability.can? :delete_issue, self
        perms << 'start' if ability.can? :start, self
        perms << 'suspend' if ability.can? :suspend, self
        perms << 'finish' if ability.can? :finish, self
        perms << 'compare' if ability.can? :compare, self
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
    	sql = "select count(*) as \"c\" from burndown_data where day=#{day} and sprint_id=#{self.id}"
    	result = ActiveRecord::Base.connection.execute(sql)
    	count = result[0]["c"]
    	if count > 0
    		sql = "update burndown_data set value = #{value} where day=#{day} and sprint_id=#{self.id}"
    		result = ActiveRecord::Base.connection.execute(sql)
    	else
    		sql = "insert into burndown_data (day, value, sprint_id) values (#{day}, #{value}, #{self.id})"
    		result = ActiveRecord::Base.connection.execute(sql)
    	end
    end

    def clear_burndown_data!
        sql = "delete from burndown_data where sprint_id=#{self.id}"
        ActiveRecord::Base.connection.execute(sql)
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
        if self.start_date && self.end_date
            start_day = self.start_date.midnight.to_i/(24*3600)
            end_day = self.end_date.midnight.to_i/(24*3600)
            xAxisData = (start_day..end_day).map do |day|
                Time.at(day*24*3600).getutc.strftime("%m/%d")
            end
            xAxisData.unshift "Start"
            ideal = (start_day..end_day).map do |day|
                (self.starting_work || 0).to_f * (1.0 - (day.to_f - start_day.to_f + 1)/(end_day.to_f - start_day.to_f + 1))
            end
            ideal.unshift self.starting_work

            actual = [self.starting_work]
            bdata = burndown_data
            data_array = bdata.map { |x| {x["day"] => x["value"] }}.reduce({}, :merge)
            today = Time.now.midnight.to_i/(24*3600)
            (start_day..[today, end_day].min).each do |day|
                this_value = data_array[day]
                if this_value
                    actual << this_value
                else
                    actual << actual[-1]
                end
            end


        	{
        		xAxisData: xAxisData,
        		ideal: ideal,
        		actual: actual
        		#projected: [nil,nil,36,24,12,0]
        	}
        end
    end

    def total_estimate
        sum = self.issues.sum(:estimate)
        [(self.starting_work || 0), sum].max
    end

    def total_work
        self.issues.flat_map {|i| i.tasks}.sum {|t| t.estimate || 0} 
    end

    def total_unassigned_work
        self.issues.flat_map {|i| i.tasks.filter {|t| !t.assignee}}.sum {|t| t.estimate || 0}
    end

    def unassigned_issues
        self.issues.flat_map {|i| i.tasks.filter {|t| !t.assignee}}.map { |t| t.issue }.uniq
    end

    def closed?
        return self.completed
    end

    #
    # day number = Time.now.to_i / (24*3600)
    # day number -> string: Time.at(a*24*3600).getutc.strftime("%m/%d")
    #


    private

    def issue_order_length
        validate_order_length(self.issues, :issue_order)
    end
end
	
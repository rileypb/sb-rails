module ApplicationHelper
	def remove_from_order(order_string, to_remove) 
		(order_string.split(',') - [to_remove.to_s]).join(',')
	end

	def remove_from_order_at(order_string, index)
		order_string ||= ''
		split = order_string.split(',')

		return split[1..-1].join(',') if index == 0

		return (split[0..(index-1)] + (split[(index+1)..-1] || [])).join(',')
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

	def insert_into_order(order_string, to_append, index)
		order_string ||= ''
		split = order_string.split(',')
		if index > 0
			new_split = split[0..(index-1)] + [to_append] + split[index..-1]
		else
			new_split = [to_append] + split
		end
		return new_split.join(',')
	end

	def _assert(exception_type, message)
		if block_given?
			raise exception_type, message unless yield
		end
	end

	def default_issue_order(record)
		order = ""
		record.issues.each do |issue|
		  if (record.is_a?(::Project) && issue.sprint) 
			continue
		  end
		  if order.present?
			order += ","
		  end
		  order += issue.id.to_s
		end 
		return order
	end

	def default_task_order(issue)
		order = ""
		issue.tasks.each do |task|
		  if order.present?
			order += ","
		  end
		  order += task.id.to_s
		end 
		return order
	end

	def default_epic_order(project)
		return project.epics.map { |epic| epic.id }.join(',')
	end
end

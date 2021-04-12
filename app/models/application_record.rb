class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def sync
  	SyncChannel.process_sync(self)
  end

  def permissions(user)
  	ability = Ability.new(user)

    a = user.project_permissions.map { |x| { scope: x.scope }}

    perms = []
    perms << 'read' if ability.can? :read, self
    perms << 'update' if ability.can? :update, self
    perms << 'delete' if ability.can? :delete, self
    return perms
  end

  def self.permissions(user)
  	ability = Ability.new(user)
  	perms = []
  	perms << 'create' if ability.can? :create, self.class
  	return perms
  end

  def validate_order(order_field)
    order = self.attributes[order_field.to_s]
    return if !order || (order.strip.length == 0)
    if order 
      order.split(',').each do |entry|
        if !(Integer(entry) rescue false)
          errors.add(order_field, "has invalid format")
        end
      end
    end
  end

  def validate_order_length(children, order_field)
    # turn off all order validation temporarily
    # if (children.count != (self.attributes[order_field.to_s] || '').split(',').count)
    #   errors.add(order_field, "length mismatch: #{self.class.name}.#{order_field}")
    # end
  end

  def create_valid_order(children, order_field)
    order = self.attributes[order_field.to_s] || ''
    order_split = order.split(',').map { |x| x.to_i }
    child_ids = children.map { |child| child.id }
    extras = order_split - child_ids
    leftovers = child_ids - order_split
    new_order_split = (order_split - extras + leftovers).uniq
    new_order = new_order_split.join(',')
    return new_order
  end

  def repair_order(children, order_field)
    return self.update_attribute(order_field, create_valid_order(children, order_field))
  end

  def self.validate_all(stop_on_failure=false, repair=false)
    Project.all.each do |project|
      if !project.valid?
        puts "Project #{project.id} not valid:"
        pp project.errors.errors
        if repair
          project.repair_order(project.epics, :epic_order)
          project.repair_order(project.issues, :issue_order)
        end
        if stop_on_failure
          return
        end
      end
    end
    Epic.all.each do |epic|
      if !epic.valid?
        puts "Epic #{epic.id} not valid:"
        pp epic.errors.errors
        if repair
          epic.repair_order(epic.issues, :issue_order)
        end
        if stop_on_failure
          return
        end
      end
    end
    Sprint.all.each do |sprint|
      if !sprint.valid?
        puts "Sprint #{sprint.id} not valid:"
        pp sprint.errors.errors
        if repair
          sprint.repair_order(sprint.issues, :issue_order)
        end
        if stop_on_failure
          return
        end
      end
    end
    Issue.all.each do |issue|
      if !issue.valid?
        puts "Issue #{issue.id} not valid:"
        pp issue.errors.errors
        if repair
          issue.repair_order(issue.tasks, :task_order)
        end
        if stop_on_failure
          return
        end
      end
    end
    "done."
  end
end

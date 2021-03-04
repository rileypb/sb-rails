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
    if order
      order.split(',').each do |entry|
        if !(Integer(entry) rescue false)
          errors.add(order_field, "has invalid format")
        end
      end
    end
  end
end

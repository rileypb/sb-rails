class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

    has_many :project_permissions
    has_many :issues, inverse_of: 'last_changed_by', foreign_key: :last_changed_by_id
    has_many :tasks, inverse_of: 'last_changed_by', foreign_key: :last_changed_by_id

    has_many :assigned_tasks, class_name: 'Task', inverse_of: 'assignee', foreign_key: :assignee_id

	def self.from_omniauth(auth)
	  u = User.where(email: auth.info.email).first
	 #  if !u
	 #  	u = User.create do |user|
	 #  		user.email = auth.info.email
		#     user.provider = auth.provider
		#     user.uid = auth.uid
		#     user.first_name = auth.info.first_name
		#     user.last_name = auth.info.last_name
		#     user.picture = auth.info.image
		#     user.password = Devise.friendly_token[0,20]
		# end
	 #  else
	 #    u.provider = auth.provider
	 #    u.uid = auth.uid
	 #    u.first_name = auth.info.first_name
	 #    u.last_name = auth.info.last_name
	 #    u.picture = auth.info.image
	 #    u.save
	 #  end

	  return u
	end

	def self.find_user_for_jwt(token)
		puts ">>> find_user_for_jwt #{token}"
		info = Rails.application.config.token_verifier.verify(token)
		puts ">>> find_user_for_jwt #{info}"
		id = info[0]["sub"]
		puts ">>> find_user_for_jwt #{id}"

		return nil unless id

		user = User.where(oauthsub: id).first
		puts ">>> find_user_for_jwt #{user}"

		if !user
			user_info = Rails.application.config.token_verifier.get_user_info(token)
    		email = user_info["email"]
    		user = User.where(email: email).first

    		if !user
			  	user = User.create! do |user|
			  		user.email = user_info["email"]
			  		user.oauthsub = id
				    user.first_name = user_info["given_name"] || user_info["nickname"] || user_info["email"] || ''
				    user.last_name = user_info["family_name"] || ''

				    # # can't use the nickname since some services automatically 
				    # # set nickname to be the left-hand part of the email address.
				    # if user_info["nickname"] 
				    # 	user.displayName = user_info["nickname"]
				    # end
				    
				    user.picture = user_info["picture"]
				    user.password = "passwordnotrequired"
				end
				project = Project.create! do |p|
					p.name = "#{user.first_name}'s Project"
					p.owner = user
				end
			else
				user.update!(oauthsub: id)
			end
		else
			# user_info = Rails.application.config.token_verifier.get_user_info(token)
			# user.email = user_info["email"]
		 #    user.first_name = user_info["given_name"]
		 #    user.last_name = user_info["family_name"]
		 #    user.picture = user_info["picture"]
		 #    user.save!
		end
		
		if user && user.blocked 
			return nil
		end

		return user
	end

	def assigned_issues
		self.assigned_tasks.map { |t| t.issue }.uniq.filter { |i| i != nil }
	end

	def admin?
	  return (self.permission_scope || "").include? "admin" 
	end

	def teacher?
	  return (self.permission_scope || "").include? "teacher" 
	end

	def label
	  "#{self.last_name}, #{first_name}"
	end

	def fullname
		if self.last_name && self.first_name
			"#{self.first_name} #{self.last_name}"
		elsif self.last_name
			self.last_name
		elsif self.first_name
			self.first_name
		else
			"NONAME"
		end
	end

	def orderable_name
		if self.displayName
			self.displayName
		elsif self.last_name && self.first_name
			"#{self.last_name}, #{self.first_name}"
		elsif self.last_name
			self.last_name
		elsif self.first_name
			self.first_name
		else
			"NONAME"
		end
	end

	def projects
		#(Project.find_by(owner_id: self.id) || []).to_ary.concat(self.project_permissions.where(scope: 'update').map { |perm| perm.project }).uniq
		Project.where(owner: self).to_a.concat(self.project_permissions.where(scope: 'read').map { |perm| perm.project }).uniq
	end
end

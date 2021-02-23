class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

    has_many :project_permissions
    has_many :issues, inverse_of: 'last_changed_by', foreign_key: :last_changed_by_id
    has_many :tasks, inverse_of: 'last_changed_by', foreign_key: :last_changed_by_id

	def self.from_omniauth(auth)
		pp auth.info
	  u = User.where(email: auth.info.email).first
	  if !u
	  	u = User.create do |user|
	  		user.email = auth.info.email
		    user.provider = auth.provider
		    user.uid = auth.uid
		    user.first_name = auth.info.first_name
		    user.last_name = auth.info.last_name
		    user.picture = auth.info.image
		    user.password = Devise.friendly_token[0,20]
		end
	  else
	    u.provider = auth.provider
	    u.uid = auth.uid
	    u.first_name = auth.info.first_name
	    u.last_name = auth.info.last_name
	    u.picture = auth.info.image
	    u.save
	  end

	  return u
	end

	def self.find_user_for_jwt(token)
		info = Rails.application.config.token_verifier.verify(token)
		id = info[0]["sub"]

		return nil unless id

		user = User.where(oauthsub: id).first

		if !user
			user_info = Rails.application.config.token_verifier.get_user_info(token)
    		email = user_info["email"]
    		user = User.where(email: email).first
    		if !user
			  	user = User.create! do |user|
			  		user.email = user_info["email"]
			  		user.oauthsub = id
				    user.first_name = user_info["given_name"]
				    user.last_name = user_info["family_name"]
				    user.picture = user_info["picture"]
				    user.password = "passwordnotrequired"
				end
			else
				user.update!(oauthsub: id)
			end
		else
			user.email = user_info["email"]
		    user.first_name = user_info["given_name"]
		    user.last_name = user_info["family_name"]
		    user.picture = user_info["picture"]
		    user.save!
		end

		return user
	end

	def admin?
	  return (self.permission_scope || "").include? "admin" 
	end

	def label
	  "#{self.last_name}, #{first_name}"
	end
end

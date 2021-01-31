class SessionsController < Devise::SessionsController
	skip_before_action :security_check

	def new
		redirect_to user_google_oauth2_omniauth_authorize_url
	end
end
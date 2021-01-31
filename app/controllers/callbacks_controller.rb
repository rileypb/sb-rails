class CallbacksController < Devise::OmniauthCallbacksController

    def google_oauth2
        @user = User.from_omniauth(request.env["omniauth.auth"])
        sign_in_and_redirect @user
    end

	def after_sign_in_path_for(resource_or_scope)
	    rails_admin_path
	end
end

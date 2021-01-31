class CallbacksController < Devise::OmniauthCallbacksController
	skip_before_action :security_check

    def google_oauth2
        @user = User.from_omniauth(request.env["omniauth.auth"])
        sign_in_and_redirect @user
    end
end

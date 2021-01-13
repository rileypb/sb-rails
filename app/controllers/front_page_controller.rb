class FrontPageController < ActionController::Base
	def show
		if current_user
			redirect_to projects_url
		end
	end
end

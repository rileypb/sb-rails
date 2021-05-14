class UsersController < ApplicationController
	skip_before_action :security_check
	# skip_before_action :authorize_request, only: [:me]

	def index
		render json: User.all
	end

	def me
		if current_user
			user_hash = { last_name: current_user.last_name, 
				first_name: current_user.first_name,
				id: current_user.id,
				picture: current_user.picture }
			perms = []
			perms << 'new-project' if can?(:create, Project)
			user_hash['permissions'] = perms
			render json: user_hash.as_json
		else
			render json: nil
		end
	end

    def profile
    	if current_user
			user_hash = { last_name: current_user.last_name, 
				first_name: current_user.first_name,
				id: current_user.id,
				picture: current_user.picture, 
				displayName: current_user.displayName,
				theme: current_user.theme }
			perms = []
			perms << 'new-project' if can?(:create, Project)
			user_hash['permissions'] = perms
			render json: user_hash.as_json
    	else
    		render json: nil, status: 403
    	end
    end

    def update
    	if current_user
    		uparams = user_params
    		if current_user.id == Integer(params[:id])
    			if current_user.update(user_params)
    				render current_user, status: :ok
    			else
    				render json: nil, status: :unprocessable_entity
    			end
    		else
    			render json: nil, status: :not_found
    		end
    	else
    		render json: nil, status: 403
    	end
    end


    private
    def user_params
    	params.require(:user).permit(:displayName, :theme)
    end
end
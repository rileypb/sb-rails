json.team do
	json.array!(@project.team_members.order(id: :desc)) do |user|
		json.partial! "users/user", user: user
	end
end
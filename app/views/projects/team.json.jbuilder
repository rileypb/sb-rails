json.team do
	json.array!(@project.team_members.sort_by { |u| u.id }) do |user|
		json.partial! "users/user", user: user
	end
end
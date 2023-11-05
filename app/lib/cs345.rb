
class Cs345
	def self.add(last_name, team_number)
		user = User.find_by_last_name(last_name)
		if !user
			puts "No such user"
			return
		end

		project = Project.find_by_name("CS345 Sp21 Team #{team_number}")
		if !project
			puts "No such project"
			return
		end

		ProjectPermission.create!(user: user, project: project, scope: "read")
		ProjectPermission.create!(user: user, project: project, scope: "update")
	end
end
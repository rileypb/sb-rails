json.extract! comment, :id, :text, :created_at, :updated_at

json.project_context do
	json.id comment.project_context_id
	json.name comment.project_context.name
end

json.user do
	json.id comment.user.id
	json.display_name (comment.user.displayName || comment.user.fullname)
	json.picture comment.user.picture
end

if comment.project_id
	json.url project_comments_url(comment, format: :json)
elsif comment.issue_id
	json.url issue_comments_url(comment, format: :json)
elsif comment.epic_id
	json.url epic_comments_url(comment, format: :json)
elsif comment.sprint_id
	json.url sprint_comments_url(comment, format: :json)
end
		
		
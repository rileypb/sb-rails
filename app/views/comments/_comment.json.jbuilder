json.extract! comment, :id, :text, :user_id, :issue_id, :epic_id, :sprint_id, :project_id, :project_context_id, :created_at, :updated_at
if comment.project_id
	json.url project_comments_url(comment, format: :json)
elsif comment.issue_id
	json.url issue_comments_url(comment, format: :json)
elsif comment.epic_id
	json.url epic_comments_url(comment, format: :json)
elsif comment.sprint_id
	json.url sprint_comments_url(comment, format: :json)
end
		
		
json.activities do 
	json.array!(@project.child_activities.order(id: :desc).limit(10)) do |activity|
		json.partial! "activities/activity", activity: activity
	end
end

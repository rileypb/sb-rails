
FactoryBot.define do
	factory :epic do
		title { 'An epic'}
		description { 'A description of an epic'}
		project
		issue_order { '' }
	end
end

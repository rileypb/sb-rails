
FactoryBot.define do
	factory :task do
		title { "A task" }
		description { "A nice task" }
		issue 
		estimate { 1 }
		state { 'Done' }
	end
end
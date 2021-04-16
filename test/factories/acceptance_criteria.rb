
FactoryBot.define do	
	factory :acceptance_criterion do
		criterion { "this is the criterion" }
		issue
		completed { false }
	end
end
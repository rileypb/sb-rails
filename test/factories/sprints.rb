
FactoryBot.define do
	sequence :title do |n|
		"Sprint #{n}"
	end
	sequence :description do |n|
		"A sprint named Sprint #{n}"
	end
	factory :sprint do
		title
		description
		project
	end
end

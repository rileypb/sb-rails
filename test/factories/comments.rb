
FactoryBot.define do
  factory :comment do
  	text { "Comment text" }
  	project_context { create(:project) }
  	user { create(:user) }
  end	
end
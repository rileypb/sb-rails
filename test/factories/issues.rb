
FactoryBot.define do
  factory :issue do
    title { "An issue" }
    description { "A really nice issue." }
    project 
    task_order { '' }
  end
end
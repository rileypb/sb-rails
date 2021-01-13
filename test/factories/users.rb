
FactoryBot.define do
  factory :user do
  	transient do 
  	  random_email { ('a'..'z').to_a.shuffle.join+ "@" + ('a'..'z').to_a.shuffle.join + ".com" }
  	end
  	first_name { "Bob" }
  	last_name { "Bobson" }
  	permission_scope { "member" }
  	email { random_email }
  	password { "password" }

  	factory :admin do 
  	  permission_scope { "admin" }
  	end

  	factory :owner do
  	end
  end
end
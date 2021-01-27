
FactoryBot.define do
  factory :user do
  	transient do 
  	  random_email { ('a'..'z').to_a.shuffle.join+ "@" + ('a'..'z').to_a.shuffle.join + ".com" }
      random_oauthsub { ('0'..'9').to_a.shuffle.join }
  	end
  	first_name { "Bob" }
  	last_name { "Bobson" }
  	permission_scope { "member" }
  	email { random_email }

  	factory :admin do 
  	  permission_scope { "admin" }
  	end

    oauthsub { random_oauthsub }

  	factory :owner do
  	end
  end
end
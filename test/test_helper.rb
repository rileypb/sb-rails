require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  add_filter "/factories/"
  add_filter %r{^/config/}  
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include Devise::Test::IntegrationHelpers
  include Warden::Test::Helpers
  include FactoryBot::Syntax::Methods

  # def log_in(user)
  # 	if integration_test?
  # 		login_as(user, :scope => :user)
  # 	else
  # 		sign_in(user)
  # 	end
  # end

  def login(user)
    get '/users/sign_in'
    sign_in user
    post user_session_url
  end

  
  def can?(user, action, obj)
    if user.is_a? Symbol
      Ability.new(create(user)).can?(action, obj)
    else
      Ability.new(user).can?(action, obj)
    end
  end

  def cannot?(user, action, obj)
    if user.is_a? Symbol
      Ability.new(create(user)).cannot?(action, obj)
    else
      Ability.new(user).cannot?(action, obj)
    end
  end
end

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

  include FactoryBot::Syntax::Methods

  
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

class ActionDispatch::IntegrationTest 
  def set_token_for(user)
    @token = user.oauthsub
  end

  def token
    @token
  end
end

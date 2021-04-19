module ApplicationCable
  class Connection < ActionCable::Connection::Base
  	identified_by :uid

    attr_accessor :current_user

  	def connect
  		self.uid = SecureRandom.uuid
  	end

  end
end

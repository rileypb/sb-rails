class NewsController < ApplicationController
	def news
		@feed = NewsItem.where(user: current_user).order(id: :desc)
	end

	def readAll
		NewsItem.where(user: current_user, seen: false).update_all(seen: true)
		sync_on 'news'
	end
end

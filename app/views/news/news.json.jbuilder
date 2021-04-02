json.news_items do
	json.array!(@feed) do |news_item|
		json.partial! "news/news_item", news_item: news_item
	end
end
json.unseen_count @feed.where(seen: false).count

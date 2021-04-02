json.news_items do
	json.array!(@feed) do |news_item|
		c = news_item.comment
		if c.project || c.epic || c.issue || c.sprint # we skip comments that have no subject - the subject was probably deleted.
			json.partial! "news/news_item", news_item: news_item
		end
	end
end
json.unseen_count @feed.where(seen: false).count

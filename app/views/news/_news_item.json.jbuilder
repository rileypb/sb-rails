json.extract! news_item, :id, :seen, :created_at
if news_item.comment
	json.comment do
		json.partial! "comments/comment", comment: news_item.comment
	end
end

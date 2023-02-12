
class GameChannel < ApplicationCable::Channel

	KEY = "dandelion"
	@@apps = {}
	@@pairs = []


	def pid(x=params[:id])
		return x.split(":")
	end

	def subscribed
		puts params
		puts "key : #{params["key"]}"
		if params["key"] != KEY
			reject
			return
		end
		player = pid[1]
		app = pid[0]
		app_players = @@apps.fetch(app, [])
		if not app_players.include?(player)
			app_players << player
			@@apps[app] = app_players
			stream_from "game:game_#{app}_#{player}"
			stream_from "game:game_#{app}"
			stream_from "game:all"
			puts "subscribed #{player}, now update_player_lists"
			broadcast_player_joined(app, player)
			update_player_lists(app)
		end
	end

	def unsubscribed
		player = pid[1]
		app = pid[0]
		@@pairs.each do |x|
			puts "... #{x}"
			if params[:id] == x[0] or params[:id] == x[1]
				match_ended(app, pid(x[0])[1], pid(x[1])[1], "#{player} disconnected")
			end
		end
		cancel(app, player)
		broadcast_player_left(app, player)
		update_player_lists(app)
	end

	def match_ended(app, player1, player2, reason)
		players = @@apps[app]
		for p in players
			GameChannel.broadcast_to "game_#{app}_#{p}", { type: "match_ended", player1: player1, player2: player2, message: reason }
		end
	end

	def broadcast_player_joined(app, player)
		players = @@apps[app]
		for p in players
			if p != player	
				GameChannel.broadcast_to "game_#{app}_#{p}", { type: "player_join", player: player }
			end
		end
	end

	def broadcast_player_left(app, player)
		players = @@apps[app]
		for p in players
			if p != player	
				GameChannel.broadcast_to "game_#{app}_#{p}", { type: "player_left", player: player }
			end
		end
	end

	def update_player_lists(app)
		players = @@apps[app]
		for player in players
			refresh_player_list_for_player(app, player)
		end
	end

	def cancel(app, player)
		app_players = @@apps.fetch(app, [])
		app_players.delete(player)

		to_remove = []
		@@pairs.each do |pair|
			if pair[0] == params[:id]
				to_remove << pair
			end
			if pair[1] == params[:id]
				to_remove << pair
			end
		end
		@@pairs -= to_remove

		stop_all_streams
	end

	def refresh_player_list(data)
		player = pid[1]
		app = pid[0]
		refresh_player_list_for_player(app, player)
	end

	def refresh_player_list_for_player(app, player)
		puts "refresh #{app}:#{player}"
		app_players = @@apps.fetch(app, [])
		return_value = available_partners(app, player)
		GameChannel.broadcast_to "game_#{app}_#{player}", { type: "player_list", players: return_value }
	end

	def player_list(ids)
		return ids.map { |x| pid(x)[1] }
	end

	def pair(data)
		player = pid[1]
		app = pid[0]
		puts data
		partner = data["partner"]
		puts "pairing #{player} and #{partner}"
		@@pairs << ["#{app}:#{player}", "#{app}:#{partner}"]
		broadcast_match_started(app, player, partner)
		update_player_lists(app)
	end

	def broadcast_match_started(app, player, partner) 
		players = @@apps[app]
		for p in players
			GameChannel.broadcast_to "game_#{app}_#{p}", { type: "match_started", player1: player, player2: partner}
		end
	end

	def relay(data)
		msg = data["message"]
		@@pairs.each do |pair|
			if pair[0] == params[:id]
				app = pid(pair[1])[0]
				player = pid(pair[1])[1]
				puts "relay #{pair[1]} #{msg}"
				GameChannel.broadcast_to "game_#{app}_#{player}", { type: "message", message: msg }
			end
			if pair[1] == params[:id]
				app = pid(pair[0])[0]
				player = pid(pair[0])[1]
				puts "relay #{pair[0]} #{msg}"
				GameChannel.broadcast_to "game_#{app}_#{player}", { type: "message", message: msg }
			end
		end
	end

	def active_players
		return player_list((@@pairs.map { |x| x[0] } + @@pairs.map { |x| x[1] })).uniq
	end

	def ping(data)
	end

	def available_partners(app, player)
		all_players = @@apps[app]
		puts "all_players = #{all_players}"
		other_players = all_players - [player]
		puts "other_players = #{other_players}"
		idle_players = other_players - active_players
		puts "idle_players = #{idle_players}"
		return idle_players
	end

end

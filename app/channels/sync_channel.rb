
class SyncChannel < ApplicationCable::Channel
  @@users = []

  @@users_per_project = Hash.new { |hash, key| hash[key] = [] }

  def subscribed
    stream_from 'sync'
  end

  def unsubscribed
    @@users.delete_at(@@users.index(current_user.id) || @@users.length)
    stop_all_streams
    update_users

    if !current_user.admin?
      projects = current_user.projects
      projects.each do |proj|
        @@users_per_project[proj.id].delete_at(@@users_per_project[proj.id].index(current_user.id) || @@users_per_project[proj.id].length)
        update_users_for_project(proj.id)
      end
    end
  end

  def receive(data)
  	puts "received #{data}"
  end


  def sync(data)
    # if current_user.admin? || data['selector'] != 'users'
      stream_from "sync:#{data['selector']}"
    # end
  end

  def cancelsync(data)
    stop_stream_from "sync:#{data['selector']}"
  end

  def auth(auth_info) 
    # pp ActionCable.server.connections
    user = User.find_user_for_jwt(auth_info['token'])
    connection.current_user = user

    if user.admin?
      stream_from "sync:users"
    end

    @@users << user.id
    update_users

    if !user.admin?
      projects = user.projects
      projects.each do |proj|
        @@users_per_project[proj.id] << user.id
        stream_from "sync:users_#{proj.id}"
        update_users_for_project(proj.id)
      end
    end
  end

  def self.broadcast_sync(sync_info) 
    sync_info.each do |info|
      self.broadcast_to info, { action: 'sync', selector: info }
    end
  end

  def update_users
    SyncChannel.broadcast_to 'users', { action: 'sync', selector: 'users', data: user_data}
  end

  def update_users_for_project(project_id)
    SyncChannel.broadcast_to "users_#{project_id}", { action: 'sync', selector: "users_#{project_id}", data: user_data_for_project(project_id)}
  end

  def user_data
    @@users.uniq.map do |userid|
      user = User.find(userid)
      { id: user.id, first_name: user.first_name, last_name: user.last_name, displayName: user.displayName, picture: user.picture }
    end
  end

  def user_data_for_project(project_id)
    @@users_per_project[project_id].uniq.map do |userid|
      user = User.find(userid)
      { id: user.id, first_name: user.first_name, last_name: user.last_name, displayName: user.displayName, picture: user.picture }
    end
  end

end

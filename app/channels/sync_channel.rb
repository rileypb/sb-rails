
class SyncChannel < ApplicationCable::Channel
  @@uuids = []

  def subscribed
    stream_from 'sync'
  end

  def unsubscribed
    stop_all_streams
    update_users
    @@uuids.delete connection.connection_identifier

    if connection.current_user
      if !connection.current_user.admin?
        projects = connection.current_user.projects
        projects.each do |proj|
          update_users_for_project(proj.id)
        end
      end
    end 
  end

  def receive(data)
  	puts "received #{data}"
  end


  def sync(data)
    # if current_user.admin? || data['selector'] != 'users'
    puts "--------------------------------- sync #{data}"
    stream_from "sync:#{data['data']['selector']}"
    # end
  end

  def cancelsync(data)
    stop_stream_from "sync:#{data['selector']}"
  end

  def auth(auth_info) 
    # pp ActionCable.server.connections
    puts "*** auth #{auth_info}"
    user = User.find_user_for_jwt(auth_info['data']['token'])
    puts ">>>>>>>>>>> auth #{user}"
    connection.current_user = user

    uuid = connection.connection_identifier

    if !@@uuids.include?(uuid)
      if user.admin?
        stream_from "sync:users"
        stream_from "sync:user_pulse"
      elsif user.teacher?
        stream_from "sync:user_pulse_#{user.id}"
        projects = user.projects
        projects.each do |proj|
          stream_from "sync:users_#{proj.id}_teacher"
          update_users_for_project(proj.id)
        end
      else
        projects = user.projects
        projects.each do |proj|
          stream_from "sync:users_#{proj.id}"
          update_users_for_project(proj.id)
        end
      end
    end

    @@uuids << uuid
    update_users
  end

  def self.broadcast_sync(sync_info) 
    sync_info.each do |info|
      self.broadcast_to info, { action: 'sync', selector: info }
    end
  end

  def update_users
    if Rails.application.config.send_active_users
      SyncChannel.broadcast_to 'users', { action: 'sync', selector: 'users', data: user_data}
    end
  end

  def update_users_for_project(project_id)
    if Rails.application.config.send_active_users
      SyncChannel.broadcast_to "users_#{project_id}", { action: 'sync', selector: "users_#{project_id}", data: user_data_for_project(project_id, false)}
      SyncChannel.broadcast_to "users_#{project_id}_teacher", { action: 'sync', selector: "users_#{project_id}", data: user_data_for_project(project_id, true)}
    end
  end

  def user_data
    all_users =  connection.server.connections.map {|c| c.current_user}.filter {|u| u}.map {|u| u.id}.uniq
    all_users.map do |userid|
      user = User.find(userid)
      { id: user.id, first_name: user.first_name, last_name: user.last_name, displayName: user.displayName, picture: user.picture }
    end
  end

  def user_data_for_project(project_id, is_teacher)
    project = Project.find(project_id)
    all_users =  connection.server.connections.map {|c| c.current_user}.filter {|u| u}.map {|u| u.id}.uniq
    team_members = project.team_members
    online_now = team_members.filter { |member| all_users.include?(member.id) && !member.admin? && (!member.teacher? || is_teacher) }
    online_now.map do |user|
      { id: user.id, first_name: user.first_name, last_name: user.last_name, displayName: user.displayName, picture: user.picture }
    end
  end

  def self.send_user_pulse(user)
    SyncChannel.broadcast_to "user_pulse", { action: 'sync', selector: "user_pulse", data: { id: user.id }}
    user.projects.map { |project| project.team_members }.flatten.uniq.filter { |tm| tm.teacher? }.each do |teacher|
      SyncChannel.broadcast_to "user_pulse_#{teacher.id}", { action: 'sync', selector: "user_pulse", data: { id: user.id }}
    end

  end

end

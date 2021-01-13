
class SyncChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'sync'
  end

  def unsubscribed
    stop_all_streams
  end

  def receive(data)
  	puts "received #{data}"
  end


  def sync(data)
    puts "********** streaming from #{data['selector']}"
    stream_from "sync:#{data['selector']}"
  end

  def cancelsync(data)
    stop_stream_from "sync:#{data['selector']}"
    puts "********** stop streaming"
  end

  def self.broadcast_sync(sync_info) 
    sync_info.each do |info|
      self.broadcast_to info, { action: 'sync', selector: info }
    end
  end


end

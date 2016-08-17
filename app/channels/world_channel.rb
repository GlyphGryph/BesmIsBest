# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorldChannel < ApplicationCable::Channel
  def subscribed
    @player_channel = "player_#{current_user}"
    @world = OpenStruct.new({id: '1'})
    @world_channel = "world_#{@world.id}"

    stream_from @player_channel
    stream_from @world_channel

    ActionCable.server.broadcast @world_channel, action: 'mapState',
      state: [[0,0,0],[0,1,0],[0,0,0]]
  end

  def unsubscribed
  end
end

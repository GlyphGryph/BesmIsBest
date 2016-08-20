# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorldChannel < ApplicationCable::Channel
  def subscribed
    @player_channel = "player_#{current_user}"
    @world = World.first || World.create!
    @character = current_user.character || Character.create!(user: current_user, xx: 0, yy: 0, world: @world)
    @world_channel = "world_#{@world.id}"

    stream_from @player_channel
    stream_from @world_channel

    ActionCable.server.broadcast @world_channel, action: 'mapState', map: @world.reload.full_map
  end

  def unsubscribed
  end

  def move(data)
    direction = data['direction']
    p "Moving player #{data}"
    if(direction=='up')
      @character.yy -= 1
      if(@character.yy < 0)
        @character.yy = 0
      end
    elsif(direction=='down')
      @character.yy += 1
      if(@character.yy >= @world.height)
        @character.yy = @world.height-1
      end
    elsif(direction=='right')
      @character.xx += 1
      if(@character.xx >= @world.width)
        @character.xx = @world.width-1
      end
    elsif(direction=='left')
      @character.xx -= 1
      if(@character.xx < 0)
        @character.xx = 0
      end
    end
    @character.save!
    p "New player position: #{@playerPosition}"
    ActionCable.server.broadcast @world_channel, action: 'mapState', map: @world.reload.full_map
    ActionCable.server.broadcast @world_channel, action: 'commandProcessed'
  end
end

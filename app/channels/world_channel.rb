# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorldChannel < ApplicationCable::Channel
  def subscribed
    @player_channel = "player_#{current_user}"
    @world = OpenStruct.new({id: '1'})
    @world_channel = "world_#{@world.id}"

    stream_from @player_channel
    stream_from @world_channel
    
    @baseMap = ->{ [[0,0,0],[0,0,0],[0,0,0]] }
    @playerPosition = {x: 1, y: 1}
    @map = @baseMap.call
    @map[@playerPosition[:y]][@playerPosition[:x]] = 1

    ActionCable.server.broadcast @world_channel, action: 'mapState', map: @map
  end

  def unsubscribed
  end

  def move(data)
    direction = data['direction']
    p "Moving player #{data}"
    if(direction=='up')
      @playerPosition[:y] -= 1
      if(@playerPosition[:y] < 0)
        @playerPosition[:y] = 0
      end
    elsif(direction=='down')
      @playerPosition[:y] += 1
      if(@playerPosition[:y] >= @map.length)
        @playerPosition[:y] = @map.length-1
      end
    elsif(direction=='right')
      @playerPosition[:x] += 1
      if(@playerPosition[:x] >= @map[0].length)
        @playerPosition[:x] = @map[0].length-1
      end
    elsif(direction=='left')
      @playerPosition[:x] -= 1
      if(@playerPosition[:x] < 0)
        @playerPosition[:x] = 0
      end
    end
    p "New player position: #{@playerPosition}"
    @map = @baseMap.call
    @map[@playerPosition[:y]][@playerPosition[:x]] = 1
    ActionCable.server.broadcast @world_channel, action: 'mapState', map: @map
    ActionCable.server.broadcast @world_channel, action: 'commandProcessed'
  end
end

# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorldChannel < ApplicationCable::Channel
  def subscribed
    @player_channel = "player_#{current_user}"
    @character = current_user.character || Character.create!(user: current_user, xx: 0, yy: 0)
    @world = OpenStruct.new({id: '1'})
    @world_channel = "world_#{@world.id}"

    stream_from @player_channel
    stream_from @world_channel
    
    @baseMap = ->{ 
      height = 5
      width = 6
      map = []
      height.times do
        row = []
        width.times do
          row.push(0)
        end
        map.push(row)
      end
      map
    }
    @map = @baseMap.call
    @map[@character.yy][@character.xx] = 1

    ActionCable.server.broadcast @world_channel, action: 'mapState', map: @map
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
      if(@character.yy >= @map.length)
        @character.yy = @map.length-1
      end
    elsif(direction=='right')
      @character.xx += 1
      if(@character.xx >= @map[0].length)
        @character.xx = @map[0].length-1
      end
    elsif(direction=='left')
      @character.xx -= 1
      if(@character.xx < 0)
        @character.xx = 0
      end
    end
    @character.save!
    p "New player position: #{@playerPosition}"
    @map = @baseMap.call
    Character.all.each do |c|
      @map[c.yy][c.xx] = 1
    end
    ActionCable.server.broadcast @world_channel, action: 'mapState', map: @map
    ActionCable.server.broadcast @world_channel, action: 'commandProcessed'
  end
end

# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorldChannel < ApplicationCable::Channel
  def subscribed
    # Join first world or create a new one
    world = World.first || World.create!
    # Create character if character does not exist
    current_user.character || Character.create!(user: current_user, xx: 0, yy: 0, world: world)

    stream_for current_user
    stream_for current_user.character.world

    WorldChannel.broadcast_to current_user, action: 'subscribed'
  end

  def unsubscribed
    current_user.character.leave_battle_mode
  end

  def move(data)
    current_user.character.move(data['direction'])
  end

  def request_update
    current_user.character.world.request_update_for(current_user)
  end

  def enter_battle
    battle = Battle.new
    battle.teams << current_user.character.team
    battle.save!
    WorldChannel.broadcast_to current_user, action: 'enterBattle'
  end

  def leave_battle
    spirit = current_user.character.team.active_spirit
    spirit.health = 0
    spirit.save!
    current_user.character.team.battle.broadcast_events
  end
end

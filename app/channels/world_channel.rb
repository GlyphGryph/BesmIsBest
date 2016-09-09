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
    current_user.character.world.broadcast_update_for(current_user)
  end

  def equip_move(data)
    current_user.character.team.spirits.find(data['spirit_id']).equip_move(data['move_id'])
  end

  def unequip_move(data)
    current_user.character.team.spirits.find(data['spirit_id']).unequip_move(data['move_id'])
  end

  def enter_battle
    battle = Battle.create
    battle.teams << current_user.character.team
    battle.add_wild_team
    battle.start
    WorldChannel.broadcast_to current_user, action: 'enterBattle'
  end

  def leave_battle
    spirit = current_user.character.team.active_spirit
    spirit.health = 0
    spirit.save!
    current_user.character.team.battle.add_battle_end
    current_user.character.team.battle.broadcast_events
  end
end

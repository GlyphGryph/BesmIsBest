# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorldChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    stream_for current_user.character.world

    current_user.character.world.broadcast_update_for(current_user)
  end

  # def unsubscribed
  #   current_user.character.leave_battle_mode
  # end

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

  def dismiss_spirit(data)
    current_user.character.team.spirits.find(data['spirit_id']).dismiss
  end

  def shift_spirit_down(data)
    current_user.character.team.spirits.find(data['spirit_id']).shift_membership_down
  end

  def shift_spirit_up(data)
    current_user.character.team.spirits.find(data['spirit_id']).shift_membership_up
  end
end

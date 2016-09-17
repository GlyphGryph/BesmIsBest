# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class BattleChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    stream_for current_user.character.team.battle
  end

  def unsubscribed
    spirit = current_user.character.team.active_spirit
    spirit.health = 0
    spirit.save!
    current_user.character.battle.advance_time
    current_user.character.battle.broadcast_events
  end

  def take_turn(data)
    current_user.character.team.battle.take_player_turn(current_user.character.team, data)
  end
end

# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class BattleChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    stream_for current_user.character.team.battle
  end

  def take_turn(data)
    current_user.character.team.reload.battle.take_player_turn(current_user.character.team, data)
  end
end

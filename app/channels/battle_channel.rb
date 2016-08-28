# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class BattleChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    stream_for current_user.character.battle

    BattleChannel.broadcast_to current_user, action: 'subscribed'
  end

  def unsubscribed
    current_user.character.leave_battle_mode
  end

  def request_update
    current_user.character.battle.request_update_for(current_user)
  end

  def action_select
  end
end

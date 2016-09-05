# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class BattleChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    stream_for current_user.character.team.battle

    BattleChannel.broadcast_to current_user, action: 'subscribed'
  end

  def unsubscribed
    spirit = current_user.character.team.active_spirit
    spirit.health = 0
    spirit.save!
    current_user.character.battle.request_update
  end

  def request_state
    current_user.character.team.battle.broadcast_state
  end

  def action_select(data)
    current_user.character.team.action_selected(data['move_id'])
    current_user.character.team.battle.advance_time
    current_user.character.team.battle.broadcast_events
  end
end

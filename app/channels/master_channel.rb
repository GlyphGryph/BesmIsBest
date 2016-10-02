class MasterChannel < ApplicationCable::Channel
  def subscribed
    # Join first world or create a new one
    world = World.first || World.create!
    # Create character if character does not exist
    current_user.character || Character.create!(user: current_user, xx: 0, yy: 0, world: world)

    stream_for current_user

    state = current_user.character.status
    MasterChannel.broadcast_to current_user, action: 'subscribed', mode: 'world', state: state
  end

  def start_battle
    current_user.character.start_battle
  end

  def join_battle
    current_user.character.join_battle
  end

  def request_battle(data)
    MasterChannel.broadcast_to Character.find(data['character_id']).user, action: 'requestBattle', source: current_user.character.view_data
  end

  def accept_battle(data)
    current_user.character.start_battle(Character.find(data['character_id']))
  end
end

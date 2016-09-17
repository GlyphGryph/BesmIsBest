class MasterChannel < ApplicationCable::Channel
  def subscribed
    # Join first world or create a new one
    world = World.first || World.create!
    # Create character if character does not exist
    current_user.character || Character.create!(user: current_user, xx: 0, yy: 0, world: world)

    stream_for current_user

    state = current_user.character.status
    MasterChannel.broadcast_to current_user, action: 'subscribed', state: state
  end

  def start_battle
    current_user.character.start_battle
  end

  def join_battle
    current_user.character.join_battle
  end
end

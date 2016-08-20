Rails.application.routes.draw do
  devise_for :users
  root 'master#begin'

  mount ActionCable.server => '/cable'
end

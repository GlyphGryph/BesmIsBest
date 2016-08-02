Rails.application.routes.draw do
  root 'master#begin'

  mount ActionCable.server => '/cable'
end

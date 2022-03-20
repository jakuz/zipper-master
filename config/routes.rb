Rails.application.routes.draw do
  root to: 'attachments#index'

  resources :attachments, only: [:new, :create]
end

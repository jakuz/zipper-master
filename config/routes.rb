Rails.application.routes.draw do
  root to: 'attachments#index'
  mount API::Base, at: "/"

  resources :attachments, only: [:new, :create]
  resources :users, only: [:new, :create]

	get '/login',     to: 'sessions#new', as: 'login'
	post '/login',    to: 'sessions#create'
	delete '/logout', to: 'sessions#destroy', as: 'logout'

end

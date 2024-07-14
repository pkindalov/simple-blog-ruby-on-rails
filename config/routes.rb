Rails.application.routes.draw do
  get 'users/show'
  root "home#index"
  get 'about', to: 'home#about'
  get 'services', to: 'home#services'
  get 'contacts', to: 'home#contacts'
  # get 'users/:id/profile', to: 'users#profile', as: 'user_profile'
  # get 'users/:id/settings', to: 'users#settings', as: 'user_settings'
  devise_for :users
  resources :users, only: [:show]
  resources :posts, only: [:new, :create, :edit, :update]
  # или
  # get 'users/:id', to: 'users#show', as: :user_profile
end

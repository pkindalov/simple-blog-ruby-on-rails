# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/show'
  root 'home#index'
  get 'about', to: 'home#about'
  get 'services', to: 'home#services'
  get 'contacts', to: 'home#contacts'
  # get 'users/:id/profile', to: 'users#profile', as: 'user_profile'
  # get 'users/:id/settings', to: 'users#settings', as: 'user_settings'
  get 'users/:id/profile', to: 'users#profile', as: 'user_profile'

  devise_for :users
  resources :users, only: [:show]
  resources :posts, only: %i[index new create edit update destroy show] do
    resources :likes, only: [:create, :destroy]
  end
  resources :posts do
    resources :comments, only: [:create]
  end
  delete 'posts/:id/photo/:photo_id', to: 'posts#delete_photo', as: 'delete_post_photo'
  delete 'users/:id/avatar', to: 'users#delete_avatar', as: 'delete_avatar'

  # или
  # get 'users/:id', to: 'users#show', as: :user_profile
end

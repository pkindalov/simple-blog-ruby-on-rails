# frozen_string_literal: true

Rails.application.routes.draw do
  # get 'messages/index'
  # get 'messages/create'
  root 'home#index'
  get 'about', to: 'home#about'
  get 'services', to: 'home#services'
  get 'contacts', to: 'home#contacts'
  get 'users/:id/profile', to: 'users#profile', as: 'user_profile'
  get 'users/:id/download_posts', to: 'users#download_posts_pdf', as: 'download_user_posts'
  get 'users/list', to: 'users#list', as: 'users_list'

  devise_for :users
  resources :users, only: [:show] do
    member do
      post 'follow', to: 'follows#create'
      delete 'unfollow', to: 'follows#destroy'
      get :followers
      get :following
      post :block, to: 'blocks#create'
      delete :unblock, to: 'blocks#destroy'
    end
    collection do
      get :popular
      get :blocked
    end
  end

  resources :posts do
    member do
      get 'download_pdf'
    end
    resources :comments, only: %i[create edit update destroy] do
      resources :likes, only: %i[create destroy]
    end
    resources :likes, only: %i[create destroy]
  end

  resources :notifications, only: %i[index destroy] do
    member do
      post :mark_as_read
      post :mark_as_unread
    end
    collection do
      post :mark_all_as_read
      post :mark_all_as_unread
      delete :delete_all
    end
  end

  # config/routes.rb
  resources :messages, only: %i[index create edit update destroy] do
    collection do
      delete :destroy_conversation
    end
  end

  delete 'posts/:id/photo/:photo_id', to: 'posts#delete_photo', as: 'delete_post_photo'
  delete 'users/:id/avatar', to: 'users#delete_avatar', as: 'delete_avatar'
end

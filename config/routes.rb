Rails.application.routes.draw do
  root 'home#index'
  get 'about', to: 'home#about'
  get 'services', to: 'home#services'
  get 'contacts', to: 'home#contacts'
  get 'users/:id/profile', to: 'users#profile', as: 'user_profile'

  devise_for :users
  resources :users, only: [:show]

  resources :posts do
    resources :comments, only: [:create, :edit, :update, :destroy] do
      resources :likes, only: [:create, :destroy]
    end
    resources :likes, only: [:create, :destroy]
  end

  delete 'posts/:id/photo/:photo_id', to: 'posts#delete_photo', as: 'delete_post_photo'
  delete 'users/:id/avatar', to: 'users#delete_avatar', as: 'delete_avatar'
end

Rails.application.routes.draw do
  devise_for :users

  resources :phrases do
    collection do
      get :archived
    end
    member do
      patch :archive
      patch :unarchive
    end
  end
  post :fetch_suggestions, to: "phrases#fetch_suggestions"
  
  resources :profile, only: [] do
    collection do
      get :settings
      patch :update
    end
  end

  resource :account do
    resource :join_code, only: [:create]
  end

  get "join/:join_code", to: "users#new", as: :join
  post "join/:join_code", to: "users#create"

  get "about", to: "static#about"
  root to: "phrases#index" # setup a Dashboard page later
end

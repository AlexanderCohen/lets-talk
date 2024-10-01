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
  
  resources :profile, only: [] do
    collection do
      get :settings
      patch :update
    end
  end

  get "about", to: "static#about"
  root to: "phrases#index" # setup a Dashboard page later
end

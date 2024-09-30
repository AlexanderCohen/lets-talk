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
  root to: "phrases#index"

  resources :profile, only: [] do
    collection do
      get :settings
      patch :update
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

end

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
  root to: "dashboard#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

end

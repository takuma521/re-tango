Rails.application.routes.draw do
  namespace :users do
    namespace :books do
      get 'words/index'
      get 'words/create'
      get 'words/delete'
      get 'words/update'
    end
  end
  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks"
  }
  devise_scope :user do
    root 'devise/sessions#new'
    get 'sign_in', to: 'devise/sessions#new'
  end

  resources :user, only: %w(show), param: :uid do
    resources :books, only: %w(index create update destroy), module: :users do
      resources :words, only: %w(index create update destroy), module: :books
    end
  end
end

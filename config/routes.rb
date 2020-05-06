Rails.application.routes.draw do

  resources :users, only: %w(show), param: :uid do
    resources :words, only: %w(index create update destroy), module: :users
  end

  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks"
  }
  devise_scope :user do
    root 'devise/sessions#new'
    get 'sign_in', to: 'devise/sessions#new'
  end

  post '/callback' => 'linebot#callback'

end

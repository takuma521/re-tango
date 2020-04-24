Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    root 'devise/sessions#new'
    get 'sign_in', to: 'devise/sessions#new'
  end

  get 'books/index'
end

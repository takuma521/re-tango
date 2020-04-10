Rails.application.routes.draw do
  get 'welcome_page/welcome'
  root 'welcome_page#welcome'
end

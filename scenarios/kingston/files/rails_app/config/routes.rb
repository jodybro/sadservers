Rails.application.routes.draw do
  root 'home#index'
  get 'health', to: 'home#index'
end
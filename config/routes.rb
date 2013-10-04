Icompressor::Application.routes.draw do
  resources :users
  root :to => 'home#index'
  match '/upload' => 'home#upload', :as => 'upload'
  match '/show' => 'home#show', :as => 'show'
end
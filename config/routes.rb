Encyclo::Application.routes.draw do
  get "sources/update"

  get "images/create"

  root :to => "home#index"

  resources :entities do
    resources :sources
    resources :images
    collection do
      get :autocomplete_name_value
      get 'search'
      get 'random'
      put 'change_parent'
    end
    member do
      put 'toggle'
	 end
  end

  resources :documents
  resources :subentities

  resources :associations
  resources :association_definitions
  
  resources :names

  resources :tags do
    collection do
      get :autocomplete_tag_name
    end
  end
  
  resources :ratings do
    member do
      put 'rank_up'
      put 'rank_down'
	 end
  end

  put "set_ranking_type" => "ranking_types#update", :as => "set_ranking_type"
  put "set_listing_type" => "listing_types#update", :as => "set_listing_type"

  post "sort" => "ratings#sort", :as => "sort"

  get "log_in" => "sessions#new", :as => "log_in"
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "sign_up" => "users#new", :as => "sign_up"

  resources :users
  resources :sessions

  root :to => "home#index"

  match "/documents/:document_name" => "documents#show", :as => "show_document"

end

Encyclo::Application.routes.draw do
  get "sources/update"

  get "images/create"

  root :to => "home#index"
  
  resources :entities do
    resources :images
    collection do
      get :autocomplete_entity_name
      get 'search'
      get 'random'
    end
    member do
      put 'tagify'
    end
  end

  resources :documents

  resources :tags do
    resources :sources
    collection do
      get :autocomplete_tag_name
      get 'random'
    end
    member do
      put 'toggle_on'
		put 'toggle_off'
	 end
  end
  
  resources :ranking_elements do
    collection do
      put 'rank'
    end
    member do
      put 'rank_up'
      put 'rank_down'
	 end
  end

  put "set_ranking_type" => "ranking_types#update", :as => "set_ranking_type"
  put "set_listing_type" => "listing_types#update", :as => "set_listing_type"

  post "sort" => "ranking_elements#sort", :as => "sort"

  get "log_in" => "sessions#new", :as => "log_in"
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "sign_up" => "users#new", :as => "sign_up"

  resources :users
  resources :sessions

  root :to => "home#index"

  match "/documents/:document_name" => "documents#show", :as => "show_document"

end

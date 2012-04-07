Encyclo::Application.routes.draw do
  get "terminal_command/create"

  get "sources/update"

  resources :images do
    resources :delete_requests, :only => :create
    resources :ratings#, :only => :update
  end

  resources :paths, :only => [:index] do
    collection do
      get 'get_entity'
      get 'get_entity_associations'
    end
  end

  root :to => "home#index"

  resources :entities do
    resources :sources
    resources :images
    resources :delete_requests, :only => :create
    resources :ratings#, :only => :update
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

  resources :delete_requests do
    member do
      put 'add_concurring_user'
      put 'add_opposing_user'
      put 'remove_concurring_user'
      put 'remove_opposing_user'
    end
  end

  resources :documents do
    resources :possible_document_types, :only => :create
    resources :delete_requests, :only => :create
    resources :ratings#, :only => :update
    collection do
      post 'upload'
    end
  end 
  resources :remote_documents, :only => :create
  resources :user_documents, :only => [:new, :create, :update]

  resources :components do
    resources :delete_requests, :only => :create
  end

  resources :associations do
    resources :delete_requests, :only => :create
  end
  
  resources :association_definitions do
    resources :delete_requests, :only => :create
  end

  resources :tags do
    collection do
      get :autocomplete_tag_name
    end
  end

  resources :names
  
  resources :ratings, :only => :destroy

  put "set_ranking_type" => "ranking_types#update", :as => "set_ranking_type"
  put "set_listing_type" => "listing_types#update", :as => "set_listing_type"

  post "sort" => "ratings#sort", :as => "sort"

  get "log_in" => "sessions#new", :as => "log_in"
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "sign_up" => "users#new", :as => "sign_up"

  resources :users
  resources :sessions do
    collection do
      get "change_language"
      get "change_document_type_filter"
      get "change_data_mode"
    end
  end

  root :to => "home#index"

  match "/documents/:document_name" => "documents#show", :as => "show_document"

end

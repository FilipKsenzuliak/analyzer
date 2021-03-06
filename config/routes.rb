Rails.application.routes.draw do
  resources :patterns
  resources :logs
  resources :users
  resources :parsers
  resources :events
  resources :synonyms
  
  root "sessions#new"

  # session
  get "sessions/new"
  get "users/new"

  # analyzer
  get "/start" => "analyzer#index"
  get "/analyze" => "analyzer#analyze"
  get "analyzer/group"
  get "/split" => "analyzer#split_element"
  get "/save_text" => "analyzer#save_text"
  get "/replace" => "analyzer#replace_data"
  post "/save_log" => "analyzer#save_log"
  post "/save_log_success" => "analyzer#save_log_success"
  get "/search" => "analyzer#help_search"
  
  # event
  get "/event" => "events#index"
  get "/taxonomy" => "events#taxonomy"
  post "/save_synonym" => "events#save_synonym"
  post "/save_event" => "events#save_event"
  post "/save_tag" => "events#save_tag"

  # session
  get "/login" => "sessions#new"
  post "/login" => "sessions#create"
  get "/logout" => "sessions#destroy"

  # user
  get "/signup" => "users#new"
  post "/users" => "users#create"
  get "/users" => "users#index"

  # parsers
  get "/parsers" => "parsers#index"
  get "/export_parsers" => "parsers#export"
  post "/form" => "parsers#form_save"
  post "/import_parsers" => "parsers#import"
  resources :parsers do
    get :autocomplete_parser_name, :on => :collection
  end

  # patterns
  get "/patterns" => "patterns#index"
  post "/save" => "patterns#create_with_log"
  get "patterns/autocomplete_pattern_text"
  get "/export_patterns" => "patterns#export"
  post "/import_patterns" => "patterns#import"

  # logs
  get "/export_logs" => "logs#export"
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root "welcome#index"

  # Example of regular route:
  #   get "products/:id" => "catalog#view"

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get "products/:id/purchase" => "catalog#purchase", as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get "short"
  #       post "toggle"
  #     end
  #
  #     collection do
  #       get "sold"
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get "recent", on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post "toggle"
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

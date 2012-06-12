KloudcatchNew::Application.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join("|")}/ do
    get "signin" => "sessions#new", :as => "signin"
    get "signin_ajax" => "sessions#ajax_new", :as => "signin_ajax"
    get "signout" => "sessions#destroy", :as => "signout"
    get "signup" => "users#new", :as => "signup"
    get "account" => "users#show", :as => "account"
    get "features" => "home#features", :as => "features"
    get "getting_started" => "home#getting_started", :as => "getting_started"
    resources :users do
      get "authorize_dropbox", :on => :collection
      post "toggle_admin", :on => :member
      get "disable_dropbox", :on => :member
      get "password_hint", :on => :collection
    end
    resources :sessions
    resources :contacts
    resources :password_resets
    root :to => 'home#index'
  end
  
  #kloudcatch server routes
  resources :droplets do
    get "html_index", :on => :collection
    get "basic_auth_login", :on => :collection
  end
  get '/synch/:id' => 'droplets#synch'
  get '/confirm/:id' => 'droplets#confirm'
  get '/pending' => 'droplets#pending'
  post '/upload' => 'droplets#upload'
  
  match '/subscribe' => 'users#subscribe', :via => [:post, :get]
  match '/unsubscribe' => 'users#unsubscribe', :via => :delete
  match '/login' => 'sessions#client_login'
  match '/logout' => 'sessions#client_logout'
  match '*path', to: redirect("/#{I18n.default_locale}/%{path}"), constraints: lambda {|req| !req.path.starts_with? "/#{I18n.default_locale}"}
  match '', to: redirect("/#{I18n.default_locale}")
end

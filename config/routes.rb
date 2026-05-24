Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/login" => "sessions#new", as: :login
  post "/login" => "sessions#create", as: :create_session
  delete "/logout" => "sessions#destroy", as: :logout

  get "/dashboard" => "dashboard#index", as: :dashboard

  # Admin resources
  scope "/admin" do
    get "profile" => "admin_resources#index", as: :admin_profile
    put "profile" => "admin_resources#update_profile", as: :update_admin_profile
    
    get ":resource" => "admin_resources#index"
    get ":resource/:id" => "admin_resources#show"
    post ":resource" => "admin_resources#create"
    put ":resource/:id" => "admin_resources#update"
    delete ":resource/:id" => "admin_resources#destroy"
  end

  root "sessions#new"
end
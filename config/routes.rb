Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token
  resource :profile, only: %i[show edit update]
  resource :registration, only: %i[new create]

  resources :workspaces, only: %i[index new create show]
  post "workspaces/:workspace_id/members",
    to: "workspace_memberships#create",
    as: :workspace_members
  delete "workspaces/:workspace_id/members/:user_id",
    to: "workspace_memberships#destroy",
    as: :workspace_member
  delete "workspaces/:workspace_id/leave",
    to: "workspace_memberships#leave",
    as: :leave_workspace
  resources :notes


  get "profile/password/edit",
    to: "profiles#edit_password",
    as: :edit_profile_password

  patch "profile/password",
    to: "profiles#update_password",
    as: :update_profile_password
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
end

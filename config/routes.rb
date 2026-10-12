Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "dashboards#show"

  resource :session, only: %i[new create destroy]
  get "login", to: "sessions#new"
  delete "logout", to: "sessions#destroy"
  resource :dashboard, only: :show
  resource :profile, only: :show
  resources :courses, only: %i[index show]
  resources :assignments, only: %i[index show new create edit update] do
    resource :submission, only: %i[create update]
  end
  resources :class_sessions, only: %i[index show new create] do
    member do
      patch :open_attendance
      patch :close_attendance
    end
  end
  get "attendance/:token", to: "attendances#show", as: :attendance
  post "attendance/:token", to: "attendances#create"
  resources :projects, only: %i[index show]
  resources :events, only: %i[index show] do
    resource :registration, controller: "event_registrations", only: %i[create destroy]
  end
  resources :complaints, only: %i[index show new create edit update] do
    resources :comments, controller: "complaint_comments", only: :create
  end
  resources :placement_drives, path: "placements", only: %i[index show] do
    resource :application, controller: "placement_applications", only: %i[create destroy]
  end
  resources :documents, only: %i[index new create]
  resources :notifications, only: %i[index update] do
    collection { patch :mark_all_read }
  end
  resource :assistant, controller: "ai_assistant", only: %i[show create destroy]
  get "search", to: "search#index"

  namespace :admin do
    root "overview#index"
    resources :users, only: %i[index show update]
    resources :departments, only: %i[index new create edit update]
  end

  namespace :api do
    namespace :v1 do
      get :me, to: "me#show"
      resources :courses, only: :index
      resources :assignments, only: :index
      resources :events, only: :index
      resources :placement_drives, only: :index
      resources :notifications, only: :index
      resources :attendance, only: :index
    end
  end
end

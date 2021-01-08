# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  # User
  devise_scope :user do
    get 'login' => 'users/sessions#new', as: :new_user_session
    post 'login' => 'users/sessions#create', as: :user_session
    delete 'logout' => 'users/sessions#destroy', as: :destroy_user_session

    get 'register' => 'users/registrations#new', as: :new_user_registration
    post 'register' => 'users/registrations#create', as: :user_registration
  end

  devise_for :users, skip: [:sessions], controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resources :home, only: :index
  resources :help, only: :index
  resources :about, only: :index

  resource :settings do
    get :json
  end

  resources :courses do
    get :share, action: :share
    put :share, action: :add_share
    delete :share, action: :delete_share

    member do
      get :copy, action: :copy
    end

    resources :assignments do
      member do
        put :programs, action: :program_add
        delete :programs, action: :program_delete

        put :input_files, action: :input_file_add
        delete :input_files, action: :input_file_delete

        get :copy, action: :copy
        post :copy_to, action: :copy_to
      end

      resources :submissions, except: [:show] do
        collection do
          get :download_all
          delete :destroy
        end
      end

      resources :ts_files, only: %i[index destroy] do
        collection do
          post :destroy_selected
          post :upload
        end
      end

      resources :rubric_items do
        collection do
          put :update
        end
      end

      resources :grading do
        resources :grade_items, only: %i[edit update show], path: '' do
          put :run
        end
      end

      resource :grades do
        post :zybooks
      end
    end
  end

  resources :rubrics
end

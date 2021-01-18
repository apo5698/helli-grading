# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  # Error pages
  %w[404 422 500].each do |status|
    get status, to: 'errors#show', status: status
  end

  # User
  devise_scope :user do
    get 'login' => 'users/sessions#new', as: :new_user_session
    post 'login' => 'users/sessions#create', as: :user_session
    delete 'logout' => 'users/sessions#destroy', as: :destroy_user_session

    get 'register' => 'users/registrations#new', as: :new_user_registration
    post 'register' => 'users/registrations#create', as: :user_registration
    get 'users/:id' => 'users/registrations#edit', as: :edit_user_registration
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
      resources :programs, only: %i[create destroy] do
        collection do
          delete :destroy_all, path: ''
        end
      end

      resources :participants do
        collection do
          delete :destroy_all, path: ''
        end
      end

      member do
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

      resources :rubric_items, path: :rubrics do
        collection do
          put :update
        end
      end

      resources :grading do
        resources :grade_items, only: %i[edit update show], path: '' do
          put :run
        end
      end

      resources :grades, only: :index do
        collection do
          get :export
          delete :destroy
        end
      end
    end
  end

  resources :rubrics

  # api.helli.app
  constraints subdomain: 'api' do
    scope module: :api do
      resources :grade_items, except: %i[index new edit]
    end
  end
end

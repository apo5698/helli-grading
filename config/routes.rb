# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  get 'help', to: 'home#help'
  get 'about', to: 'home#about'

  devise_for :users

  resource :settings do
    get :json
  end

  resources :sessions, only: %i[new create destroy]

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

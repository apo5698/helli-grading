Rails.application.routes.draw do
  resources :ts_files
  root to: 'home#index'

  get 'help', to: 'home#help'
  get 'about', to: 'home#about'

  resource :settings do
    get :json
  end

  resources :sessions, only: %i[new create destroy]

  resources :users

  resources :courses do
    get :share, action: :share
    put :share, action: :add_share
    delete :share, action: :delete_share

    resources :assignments do
      member do
        put :programs, action: :program_add
        delete :programs, action: :program_delete

        put :input_files, action: :input_file_add
        delete :input_files, action: :input_file_delete
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
        resources :grade_items, only: %i[edit update show], path: ''
      end

      resource :grades do
        post :zybooks
      end
    end
  end

  resources :rubrics
end

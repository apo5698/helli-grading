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
    get :share, action: :show_share
    put :share, action: :share

    resources :assignments do
      put :programs, action: :program_add
      delete :programs, action: :program_delete

      resources :rubrics, path: :rubric, only: [] do
        collection do
          get '', action: :show
          resources :rubric_items, only: %i[create update destroy] do
          end
        end
      end

      resources :grading, only: [:index] do
        collection do
          post :run
          delete :reset

          resources :grading_item, only: %i[edit update show]
        end
      end

      resources :submissions, only: %i[index destroy] do
        post :upload, action: :replace
        collection do
          get :download_all
          post :destroy_selected
          post :upload
        end
      end

      resources :ts_files, only: %i[index destroy] do
        collection do
          post :destroy_selected
          post :upload
        end
      end

      resource :grades do
        get :export
      end
    end
  end

  resources :rubrics, only: [:index] do
    get '', action: :show_published
    delete '', action: :delete_published
    put :adopt
  end
end
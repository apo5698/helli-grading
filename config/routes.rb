Rails.application.routes.draw do
  resources :grading do
    collection do
      resources :exercises, :projects do
        get 'prepare'
        post 'upload'
        post 'delete_upload'
        get 'compile'
        post 'compile', to: 'compile_all'
        get 'run'
        post 'run', to: 'run_selected'
        get 'checkstyle'
        post 'checkstyle', to: 'checkstyle_run'
        get 'summary'
        post 'summary'
      end
      resources :homework, as: :homeworks
    end
  end

  resources :users do
    collection do
      get 'reset_password', to: 'users#reset_password'
    end
  end

  resources :sessions

  root to: 'home#index'
end

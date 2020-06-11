Rails.application.routes.draw do
  resources :grading do
    collection do
      resources :exercises, :projects, :homework do
        get 'prepare', to: 'grading#prepare'
        post 'upload', to: 'grading#upload'
        post 'delete_upload', to: 'grading#delete_upload'
        get 'compile', to: 'grading#compile'
        post 'compile', to: 'grading#compile_all'
        get 'run', to: 'grading#run'
        post 'run', to: 'grading#run_selected'
        get 'checkstyle', to: 'grading#checkstyle'
        post 'checkstyle', to: 'grading#checkstyle_run'
        get 'summary', to: 'grading#summary'
        post 'summary', to: 'grading#summary'
      end
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

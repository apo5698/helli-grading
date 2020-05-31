Rails.application.routes.draw do
  resources :grading
  resources :users
  resources :sessions

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  get '/grading/:id/prepare', to: 'grading#prepare'
  post '/grading/:id/upload', to: 'grading#upload'
  post '/grading/:id/delete_upload', to: 'grading#delete_upload'

  get '/grading/:id/compile', to: 'grading#compile'
  post '/grading/:id/compile', to: 'grading#compile_all'

  get '/grading/:id/run', to: 'grading#run'
  post '/grading/:id/run', to: 'grading#run_selected'

  get '/grading/:id/checkstyle', to: 'grading#checkstyle'
  post '/grading/:id/checkstyle', to: 'grading#checkstyle'

  get '/grading/:id/summary', to: 'grading#summary'
  post '/grading/:id/summary', to: 'grading#summary'
end

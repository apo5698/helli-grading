Rails.application.routes.draw do
  root to: 'home#index'

	resources :sessions, only: [:new, :create, :destroy]

	resources :users

	resources :courses do
		get :share, action: :show_share
		put :share, action: :share

		resources :assignments do
			resources :rubrics, path: :rubric, only: [] do
				collection do
					get '', action: :show
					resources :rubric_items, only: [:create] do
            collection do
							delete :destroy_selected
						end
					end
				end
			end

			resources :grading, only: [:index] do
        collection do
					post :run
					post :run_all
					post :respond
				end
			end

			resources :submissions, only: [:index] do
				post :upload, action: :replace
				get '', action: :download
				collection do
					post :upload
					delete '', action: :remove
				end
			end

			resources :students, only: [:index, :create, :update, :destroy] do
				collection do
					post :load_students
					delete :destroy_selected
				end
			end

			resources :reports, path: :report, only: [:index] do
				collection do
					get :export
					get :export_aggregated
				end
			end
		end
	end

	resources :rubrics, only: [:index] do
		get '', action: :show_published
		delete '', action: :delete_published
    put :adopt
	end
end
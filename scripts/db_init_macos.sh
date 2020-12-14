rm db/schema.rb
brew services restart postgresql
rails db:environment:set RAILS_ENV=development
rake db:reset
rake db:migrate
rake db:seed

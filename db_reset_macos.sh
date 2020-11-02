#!/bin/zsh

rm db/schema.rb
brew services restart postgresql
rake db:reset
rake db:migrate
rake db:seed

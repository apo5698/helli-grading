FactoryBot.define do
  factory :dependency do
    name { Faker::App.name.downcase }
    version { Faker::App.semantic_version }
    source { Faker::Internet.url }
    source_type {}
    executable { Faker::App.name.downcase }
  end
end

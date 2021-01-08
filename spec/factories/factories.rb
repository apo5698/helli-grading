FactoryBot.define do
  factory :dependency do
    name { Faker::App.name.downcase }
    version { Faker::App.semantic_version }
    source { Faker::Internet.url }
    type { Dependency.types[:direct] }
    executable { name.downcase }
    visibility { Dependency.visibilities[:public] }
  end

  factory :course do
    name { "CSC #{Faker::Number.between(from: 111, to: 116)}" }
    section { format('%<section>03d', section: Faker::Number.between(from: 1, to: 10)) }
    term { Faker::Number.digit }
    user do
      User.create(
        name: Faker::Number.name,
        email: Faker::Internet.email,
        password: '123456',
        password_confirmation: '123456')
    end
  end

  factory :exercise, class: 'Assignment' do
    name { "Day #{Faker::Number.between(from: 1, to: 24)}" }
    category { :exercise }
    description { 'A daily exercise.' }
  end

  factory :project, class: 'Assignment' do
    name { "Project #{Faker::Number.between(from: 1, to: 6)}" }
    category { :project }
    description { 'A programming project.' }
  end

  factory :participant do
    program_total { 0 }
    zybooks_total { 0 }
    other_total { 0 }
  end

  factory :grade do
    identifier { Faker::Number.between(from: 100_000, to: 1_000_000) }
    full_name { Faker::Name.first_name + ' ' + Faker::Name.last_name }
    email_address { Faker::Internet.email(domain: 'ncsu.edu') }
    status { :submitted }
    grade {}
    maximum_grade { 10 }
    grade_can_be_changed { true }
    # noinspection RubyYardParamTypeMatch
    date = Faker::Date.between(from: 1.month.ago, to: Time.zone.today)
    last_modified_submission { date }
    last_modified_grade {}
    feedback_comments {}
  end

  factory :wce, class: 'Rubric' do
    type { Wce }
    primary_file { Dir.glob('spec/fixtures/java/wce/**/*.java').sample }
  end

  factory :user do
    name { 'User' }
    username { 'user' }
    email { 'user@helli.app' }
    password { '12345678' }
    password_confirmation { '12345678' }
    confirmed_at { Time.zone.now }
  end

  factory :unconfirmed_user, class: 'User' do
    name { 'Unconfirmed User' }
    username { 'unconfirmed_user' }
    email { 'unconfirmed_user@helli.app' }
    password { '12345678' }
    password_confirmation { '12345678' }
  end

  factory :admin, class: 'User' do
    name { 'Admin' }
    username { 'admin' }
    email { 'admin@helli.app' }
    password { '12345678' }
    password_confirmation { '12345678' }
    role { :admin }
    confirmed_at { Time.zone.now }
  end

  factory :instructor, class: 'User' do
    name { 'Instructor' }
    username { 'instructor' }
    email { 'instructor@helli.app' }
    password { '12345678' }
    password_confirmation { '12345678' }
    role { :instructor }
    confirmed_at { Time.zone.now }
  end

  factory :ta, class: 'User' do
    name { 'Teaching Assistant' }
    username { 'ta' }
    email { 'ta@helli.app' }
    password { '12345678' }
    password_confirmation { '12345678' }
    role { :ta }
    confirmed_at { Time.zone.now }
  end

  factory :student, class: 'User' do
    name { 'Student' }
    username { 'student' }
    email { 'student@helli.app' }
    password { '12345678' }
    password_confirmation { '12345678' }
    role { :student }
    confirmed_at { Time.zone.now }
  end

  # See https://github.com/thoughtbot/factory_bot/wiki/How-factory_bot-interacts-with-ActiveRecord
  #
  factory :java_source, class: 'Program' do
    initialize_with { new(name: 'Helli.java') }
  end
  #
  factory :java_test, class: 'Program' do
    initialize_with { new(name: 'HelliTest.java') }
  end
end

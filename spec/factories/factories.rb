FactoryBot.define do
  factory :dependency, class: 'Helli::Dependency' do
    name { Faker::App.name.downcase }
    version { Faker::App.semantic_version }
    source { Faker::Internet.url }
    type { Helli::Dependency.types[:direct] }
    executable { name.downcase }
    visibility { Helli::Dependency.visibilities[:public] }
  end

  factory :course do
    name { "CSC #{Faker::Number.between(from: 111, to: 116)}" }
    section { format('%<section>03d', section: Faker::Number.between(from: 1, to: 10)) }
    term { Faker::Number.digit }
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
end

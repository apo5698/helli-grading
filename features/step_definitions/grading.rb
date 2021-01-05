# frozen_string_literal: true

When(/^I want to grade an exercise called (.*) from (.*)$/) do |name, course|
  id = "#{course} TEST 2020-#{name}-123456"
  base_path = "features/fixtures/#{name}"
  csv_path = "#{base_path}/Grades-#{id}.csv"
  zip_path = "#{base_path}/#{id}.zip"
  FileUtils.mkdir_p(File.dirname(csv_path))

  # Generates CSV
  csv = Helli::Random::CSV.new(:moodle)
  csv.write(csv_path)

  # Generates submissions
  Helli::Generator::File.moodle_zip(zip_path, Helli::CSV.parse(csv.data, :moodle))

  expect(File).to exist(csv_path)
  expect(File).to exist(zip_path)
end

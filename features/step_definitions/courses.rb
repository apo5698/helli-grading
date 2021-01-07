# frozen_string_literal: true

When(/^I go to courses page and create a course called (.+ \d+) \((.+)\)$/) do |course, section|
  within '#sidebar' do
    click_link 'Courses'
  end
  expect(page).to have_current_path(courses_path)

  find('#create-course').click
  within '.modal-content' do
    fill_in 'Name', with: course
    fill_in 'Section', with: section
    click_on 'Submit'
  end

  expect(page).to have_flash :notice, text: /Course '#{course} \(#{section}\) .*' created\./
end

When(/^I go to course (.+ \d+) \((.+)\)$/) do |course, section|
  click_link "#{course} (#{section})"
  expect(page).to have_css('li.breadcrumb-item', text: /#{course} \(#{section}\)\.*/)
end

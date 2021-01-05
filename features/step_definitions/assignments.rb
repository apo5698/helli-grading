# frozen_string_literal: true

When(/^I go to course (.*) and create an? (.*) called (.*)$/) do |course, category, assignment|
  click_link 'Courses'
  click_link course
  expect(page).to have_css('li.breadcrumb-item', text: course)

  find('#create-assignment').click
  within '.modal-content' do
    fill_in 'Name', with: assignment
    select category, from: 'Category'
    click_on 'Submit'
  end
  expect(page).to have_flash(:notice)
end

When(/^I go to assignment (.*)$/) do |assignment|
  click_link assignment
  expect(page).to have_css('li.breadcrumb-item', text: assignment)
end

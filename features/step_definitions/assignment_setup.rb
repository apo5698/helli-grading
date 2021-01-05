# frozen_string_literal: true

When(/^I add a program called (.*)$/) do |file|
  fill_in 'program', with: file
  click_button 'add-program'
  expect(page).to have_flash(:notice)
  within('#programs') { expect(page).to have_content(file) }
end

When(/^I upload a moodle grade worksheet using (.*\.csv)$/) do |csv|
  attach_file 'moodle-grade-worksheet', csv, visible: :invisible
  click_button 'upload-moodle-grade-worksheet'
  expect(page).to have_flash(:notice)
end

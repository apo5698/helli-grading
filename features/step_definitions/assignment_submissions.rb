# frozen_string_literal: true

When(/^I upload a submissions zip file using (.*\.zip)$/) do |zip|
  attach_file 'zip', zip, visible: :invisible
  click_button 'upload-submissions'
  expect(page).to have_flash(:notice)
end

# frozen_string_literal: true

When(/^I run (.+) for (.*\.java) without options$/) do |ri, file|
  click_link "[#{ri}](#{file})"
  click_button 'Run'
  expect(page).not_to have_content('Inactive', wait: 10)
end

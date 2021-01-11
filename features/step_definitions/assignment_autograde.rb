# frozen_string_literal: true

When(/^I run (.+) for (.*\.java) without options$/) do |ri, file|
  click_link "[#{ri}](#{file})"
  sleep 1
  click_button 'Run'
  expect(page).to have_flash(:notice, wait: 60)
end

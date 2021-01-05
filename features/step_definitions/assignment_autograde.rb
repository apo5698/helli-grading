# frozen_string_literal: true

When(/^I run (.+) for (.*\.java) without options$/) do |ri, file|
  click_link "[#{ri}](#{file})"
  click_button 'Run'
  expect(page)._to have_flash(:notice, wait: 60)
end

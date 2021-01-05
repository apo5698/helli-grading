# frozen_string_literal: true

When(/^I click on my avatar and then 'Logout' button$/) do
  click_link 'avatar'
  click_link 'Logout'
end

Then(/^I should be able to log out$/) do
  expect(page).to have_current_path(new_session_path)
  expect(page).to have_flash :notice, text: 'You have successfully signed out.'
end

# frozen_string_literal: true

Given(/^I have registered using name (.*), email (.*), and password (.*)$/) do |name, email, password|
  User.create!(name: name, email: email, password: password, password_confirmation: password)
end

Given(/^I have logged in$/) do
  user = FactoryBot.create(:user)
  visit new_session_path
  within 'fieldset' do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
  end
  click_button 'Login'
end

When(/^I log into Helli using email (.*) and password (.*)$/) do |email, password|
  visit new_session_path
  within 'fieldset' do
    fill_in 'Email', with: email
    fill_in 'Password', with: password
  end
  click_button 'Login'
end

When(/^I log into Helli using email (.*) and a wrong password (.*)$/) do |email, wrong_password|
  visit new_session_path
  within 'fieldset' do
    fill_in 'Email', with: email
    fill_in 'Password', with: wrong_password
  end
  click_button 'Login'
end

Then(/^I should be able to view my homepage$/) do
  expect(page).to have_current_path(root_path)
  expect(page).to have_flash :notice, text: 'You have been successfully signed in.'
end

Then(/^I should not be logged in$/) do
  expect(page).to have_current_path(new_session_path)
  expect(page).to have_flash :alert, text: 'The email and password you entered did not match our records. '\
                                           'Please double-check and try again.'
end

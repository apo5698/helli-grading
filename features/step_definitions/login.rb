# frozen_string_literal: true

Given(/^I have registered using name (.*), username (.*), email (.*), and password (.*)$/) do |name, username, email, password|
  u = User.create(
    name: name,
    username: username,
    email: email,
    password: password,
    password_confirmation: password,
    confirmed_at: Time.zone.now
  )
  u.confirm
end

Given(/^I have logged in$/) do
  user = FactoryBot.create(:user)
  visit new_user_session_path
  within 'form#new_user' do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
  end
  click_button 'Log in'
end

When(/^I log into Helli using email (.*) and password (.*)$/) do |email, password|
  visit new_user_session_path
  within 'form#new_user' do
    fill_in 'Email', with: email
    fill_in 'Password', with: password
  end
  click_button 'Log in'
end

When(/^I log into Helli using email (.*) and a wrong password (.*)$/) do |email, wrong_password|
  visit new_user_session_path
  within 'form#new_user' do
    fill_in 'Email', with: email
    fill_in 'Password', with: wrong_password
  end
  click_button 'Log in'
end

Then(/^I should be able to view my homepage$/) do
  expect(page).to have_current_path(root_path)
  expect(page).to have_flash(:notice, text: I18n.t('devise.sessions.signed_in'))
end

Then(/^I should not be logged in$/) do
  expect(page).to have_current_path(new_user_session_path)
  expect(page).to have_flash(:alert, text: format(I18n.t('devise.failure.invalid'), authentication_keys: 'Email'))
end

# frozen_string_literal: true

When(/^I create a rubric item ([A-Z].+) with primary file (.+\.java) and default settings$/) do |ri, filename|
  select ri, from: '_rubric_item_type'
  click_button 'New'
  expect(page).to have_flash(:notice, text: "Rubric item for RubricItem::#{ri} created.")

  within "form[id='RubricItem::#{ri}']" do
    select filename, from: 'Primary file'
    click_button 'Save'
  end

  expect(page).to have_flash(:notice, text: "Rubric [#{ri}](#{filename}) has been updated.")
  expect(page).to have_content("[#{ri}](#{filename})")
end

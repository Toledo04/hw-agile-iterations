# frozen_string_literal: true

Then(/^the navbar should have a link to the bills page$/) do
  expect(page).to have_link('Bills', href: bills_path, visible: :all)
end

When(/^I visit the bills page$/) do
  visit bills_path
end

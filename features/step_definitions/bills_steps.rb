# frozen_string_literal: true

require 'cucumber/rspec/doubles'

Given(/^congress.gov returns a bill titled "([^"]*)"$/) do |title|
  client = instance_double(Congress::Client)
  allow(Congress::Client).to receive(:new).and_return(client)
  allow(client).to receive(:get).and_return(
    { 'bills' => [{ 'type' => 'HR', 'number' => '1', 'title' => title }], 'pagination' => { 'count' => 1 } }
  )
end

Then(/^the navbar should have a link to the bills page$/) do
  expect(page).to have_link('Bills', href: bills_path, visible: :all)
end

When(/^I visit the bills page$/) do
  visit bills_path
end

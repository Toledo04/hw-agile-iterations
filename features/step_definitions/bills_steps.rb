# frozen_string_literal: true

require 'cucumber/rspec/doubles'

Given(/^congress.gov returns a bill titled "([^"]*)"$/) do |title|
  bill = { 'type'          => 'HR',
           'number'        => '1',
           'congress'      => 119,
           'title'         => title,
           'originChamber' => 'House',
           'latestAction'  => { 'actionDate' => '2025-01-03',
                                'text'       => 'Referred to the House Committee on Energy and Commerce.' } }
  client = instance_double(Congress::Client)
  allow(Congress::Client).to receive(:new).and_return(client)
  allow(client).to receive(:get).and_return({ 'bills' => [bill], 'pagination' => { 'count' => 1 } })
end

Then(/^the navbar should have a link to the bills page$/) do
  expect(page).to have_link('Bills', href: bills_path, visible: :all)
end

When(/^I visit the bills page$/) do
  visit bills_path
end

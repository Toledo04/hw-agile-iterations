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
  @congress_client = client
end

Given(/^congress.gov provides details and a summary for the bill$/) do
  allow(@congress_client).to receive(:bill_detail).and_return(
    'bill' => {
      'congress' => 119, 'number' => 1, 'title' => 'Clean Water Act',
      'type' => 'HR', 'originChamber' => 'House'
    }
  )
  allow(@congress_client).to receive(:bill_summaries).and_return(
    'summaries' => [{ 'text' => '<p>A test bill summary.</p>' }]
  )
end

Then(/^the navbar should have a link to the bills page$/) do
  expect(page).to have_link('Bills', href: bills_path, visible: :all)
end

When(/^I visit the bills page$/) do
  visit bills_path
end

Then(/^the browser should show the saved bill record$/) do
  expect(page).to have_current_path(%r{\A/bills/\d+\z})
end

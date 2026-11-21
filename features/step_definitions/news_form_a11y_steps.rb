# frozen_string_literal: true

require 'cucumber/rspec/doubles'

Given(/^I can add news articles without logging in$/) do
  allow_any_instance_of(MyNewsItemsController).to receive(:require_login!)
end

Given(/^the representative "([^"]*)" exists$/) do |name|
  Representative.create!(name: name, title: 'representative', ocdid: "test-#{name.parameterize}")
end

When(/^I open the new news article form for "([^"]*)"$/) do |name|
  visit representative_new_my_news_item_path(Representative.find_by!(name: name))
end

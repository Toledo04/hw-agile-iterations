# frozen_string_literal: true

require 'cucumber/rspec/doubles'

Given('I am allowed to add a news article') do
  allow_any_instance_of(MyNewsItemsController).to receive(:require_login!)
end

Given('a representative is available for a news article') do
  @representative = Representative.create!(name: 'Barbara Lee', title: 'representative', ocdid: '400237')
end

When('I open the new article form for that representative') do
  visit "http://127.0.0.1#{representative_new_my_news_item_path(@representative)}"
end

When('I enter a news article titled {string} with link {string}') do |title, link|
  @news_item_title = title
  fill_in 'news_item_title', with: title
  fill_in 'Link', with: link
  fill_in 'news_item_description', with: 'An article about a current issue.'
  select @representative.name, from: 'news_item_representative_id'
end

When('I select the {string} issue') do |issue|
  select issue, from: 'news_item_issue'
end

When('I leave the issue blank') do
  page.find('#news_item_issue option[value=""]').select_option
end

When('I save the news article') do
  click_button 'Save'
end

Then('the saved article should show the {string} issue') do |issue|
  expect(page).to have_content(issue)
  expect(NewsItem.order(:id).last).to have_attributes(issue: issue, representative: @representative)
end

When('I open the representative news article list') do
  visit "http://127.0.0.1#{representative_news_items_path(@representative)}"
end

Then('the news article list should show the {string} issue') do |issue|
  expect(page).to have_css('#events thead th', text: 'Issue')
  article_row = page.find('#events tbody tr', text: @news_item_title)
  expect(article_row).to have_content(issue)
end

Then('the form should ask me to choose an issue') do
  expect(page).to have_content('Issue is not included in the list')
  expect(NewsItem.exists?(title: @news_item_title)).to be(false)
end

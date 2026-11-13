# frozen_string_literal: true

Given(/^a representative named "([^"]*)" has saved profile details:$/) do |name, table|
  details = table.rows_hash
  @representative = Representative.create!(
    name: name,
    title: 'representative',
    address: details.fetch('Address'),
    photo_url: details.fetch('Photo URL'),
    website_url: details.fetch('Website URL'),
    phone_number: details.fetch('Phone number'),
    party: details.fetch('Party')
  )
end

When("I visit that representative's profile") do
  visit representative_path(@representative)
end

Then("I should see the representative's saved profile details") do
  expect(page).to have_content(@representative.name)
  expect(page).to have_content(@representative.address)
  expect(page).to have_content(@representative.party)
  expect(page).to have_css("img[alt='Photo of #{@representative.name}'][src='#{@representative.photo_url}']")
  expect(page).to have_link('Official website', href: @representative.website_url)
  expect(page).to have_link(@representative.phone_number, href: "tel:#{@representative.phone_number}")
end

Given(/^Geocodio returns "([^"]*)" with profile details for any address$/) do |name|
  first_name, last_name = name.split(' ', 2)
  legislator = {
    'type'       => 'representative',
    'bio'        => { 'first_name' => first_name, 'last_name' => last_name, 'party' => 'Democrat' },
    'contact'    => { 'address' => '123 Capitol Ave, Washington, DC 20510',
                      'url'     => 'https://lee.house.gov',
                      'phone'   => '202-555-0100' },
    'references' => { 'govtrack_id' => '400237' }
  }
  fields = { 'congressional_districts' => [{ 'current_legislators' => [legislator] }] }
  allow(Representative).to receive(:geocodio_search)
    .and_return({ 'results' => [{ 'response' => { 'results' => [{ 'fields' => fields }] } }] })
end

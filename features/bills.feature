Feature: Bills page
  So that I can look up bills in Congress,
  I want to search congress.gov for bills from a Bills page.

Background:
  Given congress.gov returns a bill titled "Clean Water Act"

Scenario: The navbar links to the bills page
  Given I am on the homepage
  Then the navbar should have a link to the bills page

Scenario: Opening the bills page shows recent bills
  When I visit the bills page
  Then I should see "Search congress.gov for bills"
  And I should see "Clean Water Act"

Scenario: Searching by congress and bill type
  When I visit the bills page
  And I fill in "Congress" with "119"
  And I select "HR" from "Bill type"
  And I press "Search"
  Then I should see "Clean Water Act"

Scenario: Choosing a bill type without a congress number
  When I visit the bills page
  And I select "HR" from "Bill type"
  And I press "Search"
  Then I should see "Enter a congress number to search by bill type."

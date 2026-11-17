Feature: Bills page
  So that I can look up bills in Congress,
  I want a Bills page I can reach from the navbar.

Scenario: The navbar links to the bills page
  Given I am on the homepage
  Then the navbar should have a link to the bills page

Scenario: Opening the bills page
  When I visit the bills page
  Then I should see "Search congress.gov for bills"
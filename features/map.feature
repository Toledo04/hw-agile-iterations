Feature: ActionMap Shows State and County Maps

Scenario: Navigating States and counties
  Given I am on the homepage
  Then I should see "National Map"
  When I click the state "CA"
  Then I should see "California"
  And I should be on the state page for "CA"

Scenario: Clicking a county opens the county page instead of search
  Given I am on the state page for "CA"
  When I click the county with FIPS Code "001"
  Then the current page should be the county page for "CA" with FIPS Code "001"
  And I should see "Alameda County"
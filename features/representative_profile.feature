Feature: Representative profile details
  So that I can learn how to contact my representatives,
  I want to see their saved profile details on their profile page.

  Scenario: Viewing a representative's saved profile details
    Given a representative named "Barbara Lee" has saved profile details:
      | Address      | 123 Capitol Ave, Washington, DC 20510 |
      | Photo URL    | https://example.test/barbara-lee.jpg |
      | Website URL  | https://lee.house.gov                |
      | Phone number | 202-555-0100                         |
      | Party        | Democrat                             |
    When I visit that representative's profile
    Then I should see the representative's saved profile details

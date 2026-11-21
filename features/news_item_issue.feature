Feature: Tag news articles with an issue
  So that I can group articles by topic,
  I want to select an issue when adding a news article.

  Scenario: Creating a news article with an issue
    Given I am allowed to add a news article
    And a representative is available for a news article
    When I open the new article form for that representative
    And I enter a news article titled "Local immigration policy" with link "https://example.test/immigration"
    And I select the "Immigration" issue
    And I save the news article
    Then the saved article should show the "Immigration" issue
    When I open the representative news article list
    Then the news article list should show the "Immigration" issue

  Scenario: Creating a news article without an issue
    Given I am allowed to add a news article
    And a representative is available for a news article
    When I open the new article form for that representative
    And I enter a news article titled "Uncategorized article" with link "https://example.test/uncategorized"
    And I leave the issue blank
    And I save the news article
    Then the form should ask me to choose an issue

Feature: Logout
  As a user
  I want to logout from application
  So that I am able to keep my data safe

  Scenario: Logout
    Given I have logged in
    When I click on my avatar and then 'Logout' button
    Then I should be able to log out

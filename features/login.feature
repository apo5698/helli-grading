Feature: Login
  As a user
  I want to login to application
  So that I am able to use it to grade homework

  Scenario Outline: Valid credentials
    Given I have registered using name <name>, username <username>, email <email>, and password <password>
    When I log into Helli using email <email> and password <password>
    Then I should be able to view my homepage
    Examples:
      | name         | username | email             | password |
      | Dingdong Yao | dyao3    | dyao3@ncsu.edu    | 12345678 |
      | Yulin Zhang  | yzhan114 | yzhan114@ncsu.edu | 12345678 |

  Scenario Outline: Invalid credentials
    Given I have registered using name <name>, username <username>, email <email>, and password <password>
    When I log into Helli using email <email> and a wrong password <wrong_password>
    Then I should not be logged in
    Examples:
      | name         | username | email             | password | wrong_password |
      | Dingdong Yao | dyao3    | dyao3@ncsu.edu    | 12345678 | qwerty         |
      | Yulin Zhang  | yzhan114 | yzhan114@ncsu.edu | 12345678 | qwerty         |

Feature: Email-spec errors example
  These scenarios should fail with helpful messages

  Background:
    Given I am on the homepage
    And no emails have been sent
    When I fill in "Email" with "example@example.com"
    And I press "Sign up"

  Scenario: I fail to open an email with incorrect subject
    Then I should have an email
    When "example@example.com" opens the email with subject "no email"

  Scenario: I fail to open an email with incorrect text
    Then I should have an email
    When "example@example.com" opens the email with body "no email"

  Scenario: I fail to receive an email with the expected link
    Then I should have an email
    When I open the email
    When I visit "link that doesn't exist" in the email

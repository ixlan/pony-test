Feature: Prevent Bots from creating accounts

  In order to prevent bots from setting up new accounts
  As a site manager I want new users
  to verify their email address with a confirmation link

  Scenario: Signup and confirm
    Given no emails have been sent
    When I go to the homepage
	And I fill in "Name" with "Joe Someone"
	And I fill in "Email" with "example@example.com"
	And I press "Sign up"
    Then I should have 1 email
    And I should see "Account confirmation" in the email subject
    And I should see "Joe Someone" in the email body
    And I should see "confirm" in the email body

    When I visit "confirm" in the email
    Then I should see "Confirm your new account"
